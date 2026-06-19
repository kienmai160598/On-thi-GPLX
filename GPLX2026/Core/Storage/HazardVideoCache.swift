import Foundation
import os

// MARK: - HazardVideoCache

@MainActor
@Observable
final class HazardVideoCache {

    private static let logger = Logger(subsystem: "com.gplx2026", category: "HazardVideoCache")

    private(set) var downloadProgress: [Int: Double] = [:]
    private(set) var isDownloadingAll = false
    private(set) var downloadSpeedMBps: Double = 0
    private(set) var downloadingChapters: Set<Int> = []
    private(set) var isPausedAll = false
    private(set) var pausedChapters: Set<Int> = []
    private(set) var cachedCount: Int = 0
    private(set) var cacheSizeMB: Double = 0
    /// Situations whose most recent download attempt failed (network/server/cert).
    /// Surfaced to the UI so failures aren't silent; cleared on retry or success.
    private(set) var failedIds: Set<Int> = []
    private var cachedIds: Set<Int> = []
    private var activeTasks: [Int: URLSessionTask] = [:]

    private var speedWindowBytes: Int64 = 0
    private var speedWindowStart: Date?

    // PERF5: Lazy stats — don't scan files in init()
    private var _statsLoaded = false

    // PERF4: Shared session + delegate
    private let downloadDelegate = SharedDownloadDelegate()
    @ObservationIgnored
    private lazy var downloadSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 300
        return URLSession(configuration: config, delegate: downloadDelegate, delegateQueue: nil)
    }()

    init() {
        // No file I/O here — stats loaded lazily
    }

    // MARK: - Cache directory

    nonisolated static var cacheDir: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("hazard_videos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - Public API

    func localURL(for situation: HazardSituation) -> URL? {
        let file = Self.cacheDir.appendingPathComponent("\(situation.videoFileName).mp4")
        return FileManager.default.fileExists(atPath: file.path) ? file : nil
    }

    func playableURL(for situation: HazardSituation) -> URL {
        localURL(for: situation) ?? situation.videoURL
    }

    var totalCount: Int { HazardSituation.all.count }

    var isCached: Bool { cachedCount == totalCount }

    var isDownloading: Bool {
        isDownloadingAll || !downloadingChapters.isEmpty
    }

    func cachedCount(forChapter chapterId: Int) -> Int {
        ensureStatsLoaded()
        return HazardSituation.all
            .filter { $0.chapter == chapterId && cachedIds.contains($0.id) }
            .count
    }

    func totalCount(forChapter chapterId: Int) -> Int {
        HazardSituation.all.filter { $0.chapter == chapterId }.count
    }

    /// Trigger lazy stats load. Call from views that display cache info.
    func ensureStatsLoaded() {
        guard !_statsLoaded else { return }
        _statsLoaded = true
        let cacheDir = Self.cacheDir
        let allSituations = HazardSituation.all
        Task.detached {
            var ids = Set<Int>()
            for situation in allSituations {
                let file = cacheDir.appendingPathComponent("\(situation.videoFileName).mp4")
                if FileManager.default.fileExists(atPath: file.path) {
                    ids.insert(situation.id)
                }
            }
            let sizeMB = Self.computeCacheSizeMB(cacheDir: cacheDir)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.cachedIds = ids
                self.cachedCount = ids.count
                self.cacheSizeMB = sizeMB
            }
        }
    }

    private nonisolated static func computeCacheSizeMB(cacheDir: URL) -> Double {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: cacheDir,
            includingPropertiesForKeys: [.fileSizeKey]
        )) ?? []
        let totalBytes = files.reduce(0) { sum, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return sum + size
        }
        return Double(totalBytes) / (1024 * 1024)
    }

    private func fileSizeMB(_ url: URL) -> Double {
        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        return Double(size) / (1024 * 1024)
    }

    // MARK: - Downloads

    func downloadChapter(_ chapterId: Int) async {
        ensureStatsLoaded()
        pausedChapters.remove(chapterId)
        downloadingChapters.insert(chapterId)
        let uncached = HazardSituation.all
            .filter { $0.chapter == chapterId && localURL(for: $0) == nil }

        for situation in uncached {
            guard downloadingChapters.contains(chapterId) else { break }
            await downloadVideo(for: situation)
        }

        downloadingChapters.remove(chapterId)
        resetSpeedIfIdle()
        if !pausedChapters.contains(chapterId) {
            let chapterIds = Set(HazardSituation.all.filter { $0.chapter == chapterId }.map(\.id))
            let chapterFailed = !failedIds.isDisjoint(with: chapterIds)
            Haptics.notification(chapterFailed ? .warning : .success)
        }
    }

    func pauseChapter(_ chapterId: Int) {
        pausedChapters.insert(chapterId)
        downloadingChapters.remove(chapterId)
        let chapterSituations = HazardSituation.all.filter { $0.chapter == chapterId }
        for s in chapterSituations {
            if let task = activeTasks.removeValue(forKey: s.id) {
                task.cancel()
            }
        }
        resetSpeedIfIdle()
    }

    func downloadVideo(for situation: HazardSituation) async {
        guard localURL(for: situation) == nil else { return }
        downloadProgress[situation.id] = 0
        failedIds.remove(situation.id)

        do {
            let tempURL: URL = try await withCheckedThrowingContinuation { continuation in
                let task = downloadSession.downloadTask(with: situation.videoURL)
                downloadDelegate.register(
                    taskId: task.taskIdentifier,
                    onProgress: { [weak self] bytesWritten, totalWritten, expected in
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            if expected > 0 {
                                self.downloadProgress[situation.id] = Double(totalWritten) / Double(expected)
                            }
                            self.trackSpeed(bytesJustWritten: bytesWritten)
                        }
                    },
                    continuation: continuation
                )
                self.activeTasks[situation.id] = task
                task.resume()
            }

            activeTasks.removeValue(forKey: situation.id)
            let dest = Self.cacheDir.appendingPathComponent("\(situation.videoFileName).mp4")
            try? FileManager.default.removeItem(at: dest)
            try FileManager.default.moveItem(at: tempURL, to: dest)
            downloadProgress[situation.id] = 1.0
            // PERF5: Incremental update instead of full rescan
            cachedIds.insert(situation.id)
            cachedCount = cachedIds.count
            cacheSizeMB += fileSizeMB(dest)
            Self.logger.info("Cached video \(situation.id)")
        } catch {
            activeTasks.removeValue(forKey: situation.id)
            downloadProgress.removeValue(forKey: situation.id)
            // A user-initiated pause/cancel isn't a real failure — only flag
            // genuine errors (no network, server 404, cert pin mismatch, …).
            if (error as NSError).code != NSURLErrorCancelled {
                failedIds.insert(situation.id)
                Self.logger.error("Failed to download video \(situation.id): \(error.localizedDescription)")
            }
        }
    }

    func downloadAll() async {
        ensureStatsLoaded()
        isPausedAll = false
        isDownloadingAll = true
        let uncached = HazardSituation.all.filter { localURL(for: $0) == nil }

        // Download up to 4 videos concurrently to saturate the connection without
        // overwhelming it. We add tasks in batches: once 4 are in flight we wait
        // for one to finish before adding the next, keeping the window at most 4.
        await withTaskGroup(of: Void.self) { group in
            var inFlight = 0
            for situation in uncached {
                guard isDownloadingAll else { break }

                group.addTask {
                    await self.downloadVideo(for: situation)
                }
                inFlight += 1

                // When the window is full, drain one slot before continuing.
                if inFlight >= 4 {
                    await group.next()
                    inFlight -= 1
                }
            }
        }

        isDownloadingAll = false
        resetSpeedIfIdle()
        if !isPausedAll {
            Haptics.notification(failedIds.isEmpty ? .success : .warning)
        }
    }

    func pauseAll() {
        isPausedAll = true
        isDownloadingAll = false
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
        downloadProgress.removeAll()
        downloadingChapters.removeAll()
        resetSpeedIfIdle()
    }

    func cancelAll() {
        isPausedAll = false
        pausedChapters.removeAll()
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
        downloadProgress.removeAll()
        downloadingChapters.removeAll()
        isDownloadingAll = false
        resetSpeedIfIdle()
    }

    func clearCache() {
        try? FileManager.default.removeItem(at: Self.cacheDir)
        try? FileManager.default.createDirectory(at: Self.cacheDir, withIntermediateDirectories: true)
        downloadProgress.removeAll()
        cachedIds.removeAll()
        failedIds.removeAll()
        cachedCount = 0
        cacheSizeMB = 0
        isPausedAll = false
        pausedChapters.removeAll()
    }

    // MARK: - Speed tracking

    private func trackSpeed(bytesJustWritten: Int64) {
        let now = Date()
        guard let start = speedWindowStart else {
            speedWindowStart = now
            speedWindowBytes = bytesJustWritten
            return
        }
        speedWindowBytes += bytesJustWritten
        let elapsed = now.timeIntervalSince(start)
        if elapsed >= 0.5 {
            downloadSpeedMBps = Double(speedWindowBytes) / elapsed / (1024 * 1024)
            speedWindowStart = now
            speedWindowBytes = 0
        }
    }

    private func resetSpeedIfIdle() {
        if !isDownloading {
            downloadSpeedMBps = 0
            speedWindowBytes = 0
            speedWindowStart = nil
        }
    }
}

// MARK: - Shared Download Delegate

// Thread-safety contract for @unchecked Sendable:
// URLSessionDelegate callbacks arrive on an arbitrary background thread (the
// session's delegateQueue). All mutable state — `progressHandlers` and
// `continuations` — is exclusively accessed inside `lock.withLock { … }`,
// which serialises every read and write. The closures stored in
// `progressHandlers` are themselves `@Sendable`, so they are safe to call
// from any thread. No mutable state is ever touched without the lock, making
// the @unchecked Sendable conformance correct by construction.
private final class SharedDownloadDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var progressHandlers: [Int: @Sendable (Int64, Int64, Int64) -> Void] = [:]
    private var continuations: [Int: CheckedContinuation<URL, Error>] = [:]

    func register(
        taskId: Int,
        onProgress: @escaping @Sendable (Int64, Int64, Int64) -> Void,
        continuation: CheckedContinuation<URL, Error>
    ) {
        lock.withLock {
            progressHandlers[taskId] = onProgress
            continuations[taskId] = continuation
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let id = downloadTask.taskIdentifier
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        do {
            try FileManager.default.copyItem(at: location, to: tempFile)
            lock.withLock { continuations.removeValue(forKey: id) }?.resume(returning: tempFile)
        } catch {
            lock.withLock { continuations.removeValue(forKey: id) }?.resume(throwing: error)
        }
        lock.withLock { _ = progressHandlers.removeValue(forKey: id) }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let handler = lock.withLock { progressHandlers[downloadTask.taskIdentifier] }
        handler?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let id = task.taskIdentifier
        if let error {
            lock.withLock { continuations.removeValue(forKey: id) }?.resume(throwing: error)
        }
        lock.withLock { _ = progressHandlers.removeValue(forKey: id) }
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if CertificatePinner.validate(challenge: challenge),
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
