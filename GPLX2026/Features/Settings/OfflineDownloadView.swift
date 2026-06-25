import SwiftUI

// MARK: - OfflineDownloadView (design mfexH)

struct OfflineDownloadView: View {
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(ThemeStore.self) private var themeStore

    @AppStorage("wifiOnlyDownload") private var wifiOnlyDownload: Bool = true

    @State private var showClearConfirm = false
    @State private var freeSpaceGB: Double = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                storageCard
                sectionLabel("THEO CHƯƠNG")
                wifiCard
                chaptersCard
                Spacer(minLength: 8)
                downloadAllButton
                clearAllButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
        }
        .screenHeader("Tải offline", titleDisplayMode: .inline)
        .onAppear { videoCache.ensureStatsLoaded() }
        .task { freeSpaceGB = await Self.fetchFreeSpaceGB() }
        .confirmationDialog(
            "Xác nhận xoá tất cả video đã tải?",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("Xoá", role: .destructive) { videoCache.clearCache() }
            Button("Huỷ", role: .cancel) {}
        }
    }

    // MARK: - Shared card chrome

    private func card<Content: View>(
        cornerRadius: CGFloat = 20,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        content()
            .background(Color.cardTranslucent, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            )
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.appSans(size: 10, weight: .heavy))
            .foregroundStyle(Color(hex: 0x7A7166))
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private func iconBox(_ icon: String) -> some View {
        IconBox(icon: icon, color: themeStore.primaryColor, size: 36,
                cornerRadius: 8, iconFontSize: 18, background: Color.neutralWash)
    }

    // MARK: - Storage Card

    private var storageCard: some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                Text("BỘ NHỚ ĐÃ DÙNG")
                    .font(.appSans(size: 10, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x7A7166))
                    .tracking(1.2)

                HStack(alignment: .bottom, spacing: 6) {
                    Text(cacheSizeText)
                        .font(.appSans(size: 30, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Spacer()
                    Text("còn trống \(freeSpaceText)")
                        .font(.appSans(size: 12.5, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x7A7166))
                        .padding(.bottom, 4)
                }
            }
            .padding(12)
        }
    }

    private var cacheSizeText: String {
        let mb = videoCache.cacheSizeMB
        return mb >= 1024 ? String(format: "%.1f GB", mb / 1024) : String(format: "%.0f MB", mb)
    }

    private var freeSpaceText: String {
        freeSpaceGB >= 1 ? String(format: "%.1f GB", freeSpaceGB) : String(format: "%.0f MB", freeSpaceGB * 1024)
    }

    // MARK: - Wi-Fi Card

    private var wifiCard: some View {
        card(cornerRadius: 16) {
            HStack(spacing: 12) {
                iconBox("wifi")

                Text("Chỉ tải qua Wi-Fi")
                    .font(.appSans(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Toggle("", isOn: $wifiOnlyDownload)
                    .labelsHidden()
                    .tint(themeStore.primaryColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Chỉ tải qua Wi-Fi")
        .accessibilityValue(wifiOnlyDownload ? "Bật" : "Tắt")
    }

    // MARK: - Chapters Card

    private var chaptersCard: some View {
        card {
            VStack(spacing: 0) {
                ForEach(Array(HazardSituation.chapters.enumerated()), id: \.element.id) { index, chapter in
                    chapterRow(chapter)
                    if index < HazardSituation.chapters.count - 1 {
                        Rectangle()
                            .fill(Color(hex: 0x000000, opacity: 0.06))
                            .frame(height: 1)
                    }
                }
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 12)
        }
    }

    private func chapterRow(_ chapter: HazardSituation.Chapter) -> some View {
        let cached = videoCache.cachedCount(forChapter: chapter.id)
        let total = videoCache.totalCount(forChapter: chapter.id)
        let isDownloading = videoCache.downloadingChapters.contains(chapter.id)
        let isPaused = videoCache.pausedChapters.contains(chapter.id)
        let isFullyCached = cached == total && total > 0

        return HStack(spacing: 12) {
            iconBox(chapterIcon(for: chapter.id))

            VStack(alignment: .leading, spacing: 2) {
                Text(chapter.name)
                    .font(.appSans(size: 13.5, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(2)
                Text(chapterSubtitle(chapter: chapter, cached: cached, total: total, isDownloading: isDownloading))
                    .font(.appSans(size: 11.5, weight: .medium))
                    .foregroundStyle(Color(hex: 0x7A7166))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            chapterStateButton(chapter: chapter, isFullyCached: isFullyCached,
                               isDownloading: isDownloading, isPaused: isPaused)
        }
        .padding(.vertical, 10)
    }

    private func chapterSubtitle(chapter: HazardSituation.Chapter, cached: Int, total: Int, isDownloading: Bool) -> String {
        if isDownloading {
            let pct = Int(chapterProgress(chapterId: chapter.id, total: total) * 100)
            return "\(total) video · đang tải \(pct)%"
        } else if cached == total && total > 0 {
            return "\(total) video · đã tải \(Int(chapterCacheSizeMB(chapterId: chapter.id))) MB"
        } else if cached > 0 {
            return "\(total) video · \(cached) đã tải"
        } else {
            return "\(total) video"
        }
    }

    private func chapterProgress(chapterId: Int, total: Int) -> Double {
        let situations = HazardSituation.all.filter { $0.chapter == chapterId }
        guard !situations.isEmpty else { return 0 }
        let totalProgress = situations.reduce(0.0) { $0 + (videoCache.downloadProgress[$1.id] ?? 0) }
        return totalProgress / Double(situations.count)
    }

    private func chapterCacheSizeMB(chapterId: Int) -> Double {
        let chapterCount = videoCache.totalCount(forChapter: chapterId)
        let totalCount = videoCache.totalCount
        guard totalCount > 0 else { return 0 }
        return videoCache.cacheSizeMB * Double(chapterCount) / Double(totalCount)
    }

    /// Circular state badge (design: 36×36, color-coded by download state).
    @ViewBuilder
    private func chapterStateButton(chapter: HazardSituation.Chapter, isFullyCached: Bool, isDownloading: Bool, isPaused: Bool) -> some View {
        let size: CGFloat = 36
        if isFullyCached {
            ZStack {
                Circle().fill(Color(hex: 0xD9F0DA))
                Image(systemName: "checkmark")
                    .font(.appSans(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x1F5A2A))
            }
            .frame(width: size, height: size)
            .accessibilityLabel("Đã tải xong — chương \(chapter.id)")
            .accessibilityAddTraits(.isStaticText)
        } else if isDownloading {
            Button { videoCache.pauseChapter(chapter.id) } label: {
                ZStack {
                    Circle().fill(themeStore.primaryColor.opacity(0.12))
                    Image(systemName: "pause.fill")
                        .font(.appSans(size: 16, weight: .semibold))
                        .foregroundStyle(themeStore.primaryColor)
                }
                .frame(width: size, height: size)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tạm dừng chương \(chapter.id)")
        } else if isPaused {
            Button { Task { await videoCache.downloadChapter(chapter.id) } } label: {
                ZStack {
                    Circle().fill(themeStore.primaryColor.opacity(0.12))
                    Image(systemName: "arrow.down")
                        .font(.appSans(size: 16, weight: .semibold))
                        .foregroundStyle(themeStore.primaryColor)
                }
                .frame(width: size, height: size)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tiếp tục tải chương \(chapter.id)")
        } else {
            Button { Task { await videoCache.downloadChapter(chapter.id) } } label: {
                ZStack {
                    Circle().fill(themeStore.primaryColor)
                    Image(systemName: "arrow.down")
                        .font(.appSans(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .frame(width: size, height: size)
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tải chương \(chapter.id)")
        }
    }

    // MARK: - Bottom actions

    private var downloadAllButton: some View {
        Button {
            if videoCache.isDownloadingAll {
                videoCache.pauseAll()
            } else if !videoCache.isCached {
                Task { await videoCache.downloadAll() }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: downloadAllIcon)
                    .font(.appSans(size: 17))
                Text(downloadAllLabel)
                    .font(.appSans(size: 14.5, weight: .bold))
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(themeStore.primaryColor, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(videoCache.isCached && !videoCache.isDownloadingAll)
    }

    private var downloadAllIcon: String {
        if videoCache.isDownloadingAll { return "pause.fill" }
        else if videoCache.isCached { return "checkmark" }
        else { return "arrow.down.circle.fill" }
    }

    private var downloadAllLabel: String {
        if videoCache.isDownloadingAll {
            return String(format: "Dừng tải · %.1f MB/s", videoCache.downloadSpeedMBps)
        } else if videoCache.isCached {
            return "Đã tải xong · \(videoCache.cachedCount) video"
        } else {
            return "Tải tất cả · \(videoCache.totalCount) video"
        }
    }

    private var clearAllButton: some View {
        Button { showClearConfirm = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.appSans(size: 16))
                Text("Xoá tất cả video")
                    .font(.appSans(size: 14.5, weight: .bold))
            }
            .foregroundStyle(Color(hex: 0x8A2A1F))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(hex: 0x8A2A1F, opacity: 0.06), in: RoundedRectangle(cornerRadius: 25, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .strokeBorder(Color(hex: 0x8A2A1F, opacity: 0.15), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(videoCache.cacheSizeMB <= 0)
        .opacity(videoCache.cacheSizeMB <= 0 ? 0.5 : 1)
    }

    // MARK: - Chapter icon (uniform neutral box + accent glyph, design oRlc7)

    private func chapterIcon(for chapterId: Int) -> String {
        switch chapterId {
        case 1: return "building.2.fill"
        case 2: return "road.lanes"
        case 3: return "car.fill"
        case 4: return "mountain.2.fill"
        case 5: return "map.fill"
        default: return "exclamationmark.triangle.fill"
        }
    }

    // MARK: - Free space

    private static func fetchFreeSpaceGB() async -> Double {
        await Task.detached {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let values = try? url?.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            let bytes = values?.volumeAvailableCapacityForImportantUsage ?? 0
            return Double(bytes) / (1024 * 1024 * 1024)
        }.value
    }
}
