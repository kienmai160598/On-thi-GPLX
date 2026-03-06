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
    private var activeTasks: [Int: URLSessionTask] = [:]
    private var _cacheVersion = 0

    private var speedWindowBytes: Int64 = 0
    private var speedWindowStart: Date?

    // MARK: - Cache directory

    private static var cacheDir: URL {
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

    var cachedCount: Int {
        _ = _cacheVersion
        return HazardSituation.all.filter { localURL(for: $0) != nil }.count
    }

    var totalCount: Int { HazardSituation.all.count }

    var isCached: Bool { cachedCount == totalCount }

    var isDownloading: Bool {
        isDownloadingAll || !downloadingChapters.isEmpty
    }

    func cachedCount(forChapter chapterId: Int) -> Int {
        _ = _cacheVersion
        return HazardSituation.all
            .filter { $0.chapter == chapterId && localURL(for: $0) != nil }
            .count
    }

    func totalCount(forChapter chapterId: Int) -> Int {
        HazardSituation.all.filter { $0.chapter == chapterId }.count
    }

    func downloadChapter(_ chapterId: Int) async {
        downloadingChapters.insert(chapterId)
        let uncached = HazardSituation.all
            .filter { $0.chapter == chapterId && localURL(for: $0) == nil }

        for situation in uncached {
            guard downloadingChapters.contains(chapterId) else { break }
            await downloadVideo(for: situation)
        }

        downloadingChapters.remove(chapterId)
        resetSpeedIfIdle()
        Haptics.notification(.success)
    }

    func cancelChapter(_ chapterId: Int) {
        downloadingChapters.remove(chapterId)
        // Cancel active tasks for this chapter
        let chapterSituations = HazardSituation.all.filter { $0.chapter == chapterId }
        for s in chapterSituations {
            if let task = activeTasks.removeValue(forKey: s.id) {
                task.cancel()
            }
        }
    }

    func downloadVideo(for situation: HazardSituation) async {
        guard localURL(for: situation) == nil else { return }
        downloadProgress[situation.id] = 0

        let delegate = DownloadProgressTracker { [weak self] bytesJustWritten, totalWritten, expectedTotal in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if expectedTotal > 0 {
                    self.downloadProgress[situation.id] = Double(totalWritten) / Double(expectedTotal)
                }
                self.trackSpeed(bytesJustWritten: bytesJustWritten)
            }
        }

        do {
            let tempURL: URL = try await withCheckedThrowingContinuation { continuation in
                delegate.continuation = continuation
                let config = URLSessionConfiguration.default
                config.timeoutIntervalForResource = 300
                let dlSession = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
                let task = dlSession.downloadTask(with: situation.videoURL)
                self.activeTasks[situation.id] = task
                task.resume()
            }

            activeTasks.removeValue(forKey: situation.id)
            let dest = Self.cacheDir.appendingPathComponent("\(situation.videoFileName).mp4")
            try? FileManager.default.removeItem(at: dest)
            try FileManager.default.moveItem(at: tempURL, to: dest)
            downloadProgress[situation.id] = 1.0
            _cacheVersion += 1
            Self.logger.info("Cached video \(situation.id)")
        } catch {
            activeTasks.removeValue(forKey: situation.id)
            downloadProgress.removeValue(forKey: situation.id)
            if (error as NSError).code != NSURLErrorCancelled {
                Self.logger.error("Failed to download video \(situation.id): \(error.localizedDescription)")
            }
        }
    }

    func downloadAll() async {
        isDownloadingAll = true
        let uncached = HazardSituation.all.filter { localURL(for: $0) == nil }

        for situation in uncached {
            guard isDownloadingAll else { break }
            await downloadVideo(for: situation)
        }

        isDownloadingAll = false
        resetSpeedIfIdle()
        Haptics.notification(.success)
    }

    func cancelAll() {
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
        _cacheVersion += 1
    }

    var cacheSizeMB: Double {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: Self.cacheDir,
            includingPropertiesForKeys: [.fileSizeKey]
        )) ?? []

        let totalBytes = files.reduce(0) { sum, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return sum + size
        }

        return Double(totalBytes) / (1024 * 1024)
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

// MARK: - Download Progress Delegate

private final class DownloadProgressTracker: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    let onProgress: @Sendable (Int64, Int64, Int64) -> Void
    var continuation: CheckedContinuation<URL, Error>?

    init(onProgress: @escaping @Sendable (Int64, Int64, Int64) -> Void) {
        self.onProgress = onProgress
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        try? FileManager.default.copyItem(at: location, to: tempFile)
        continuation?.resume(returning: tempFile)
        continuation = nil
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        onProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }
}
