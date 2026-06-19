import SwiftUI

struct PracticeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(ThemeStore.self) private var themeStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.openExam) private var openExam

    @State private var showClearCacheAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                questionSection
                hazardSection
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .glassContainer()
        }
        .screenHeader("Luyện tập")
    }

    // MARK: - Câu hỏi Section

    @ViewBuilder
    private var questionSection: some View {
        let allTopics = questionStore.topics
        let topicStats = progressStore.weakTopics(topics: allTopics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }
        let totalCount = allTopics.reduce(0) { $0 + $1.questionCount }

        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Câu hỏi")

            Button {
                openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
            } label: {
                AppButton(icon: "play.fill", label: "Ôn tập \(totalCount) câu", height: metrics.buttonHeight)
            }

            // Topic grid with color-coded progress rings
            AdaptiveGrid {
                ForEach(topicStats, id: \.topic.id) { item in
                    let topicAccuracy = item.total > 0 ? Double(item.correct) / Double(item.total) : 0
                    let ringColor = topicRingColor(accuracy: topicAccuracy, attempted: item.attempted > 0)

                    Button {
                        openExam(.questionView(topicKey: item.topic.key, startIndex: 0))
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(item.topic.name)
                                    .font(.appSans(size: 16, weight: .bold))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                HStack(spacing: 6) {
                                    TagPill(text: "\(item.total) câu")
                                    if item.attempted > 0 {
                                        TagPill(text: "\(Int(topicAccuracy * 100))% đúng", color: ringColor)
                                    }
                                }
                            }

                            Spacer(minLength: 8)

                            CircularActionButton(icon: "play.fill")
                        }
                        .padding(metrics.cardPadding)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .glassCard()
                }
            }
        }
    }

    // MARK: - Tình huống Section

    @ViewBuilder
    private var hazardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Tình huống nguy hiểm")

            // Compact download status bar
            hazardDownloadBar

            // Chapter grid with progress rings + download indicators
            AdaptiveGrid {
                ForEach(HazardSituation.chapters, id: \.id) { chapter in
                    hazardChapterCard(chapter)
                }
            }
        }
        .alert("Xoá cache video?", isPresented: $showClearCacheAlert) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá", role: .destructive) {
                videoCache.clearCache()
                Haptics.notification(.success)
            }
        } message: {
            Text("Tất cả video đã tải sẽ bị xoá. Bạn có thể tải lại sau.")
        }
        .onAppear { videoCache.ensureStatsLoaded() }
    }

    // MARK: - Download Status Bar

    @ViewBuilder
    private var hazardDownloadBar: some View {
        let cached = videoCache.cachedCount
        let total = videoCache.totalCount
        let fraction = total > 0 ? Double(cached) / Double(total) : 0
        let allComplete = cached == total

        HStack(spacing: 10) {
            Image(systemName: allComplete ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
                .font(.appSans(size: 14))
                .foregroundStyle(themeStore.primaryColor)
                .symbolRenderingMode(.hierarchical)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(allComplete ? "Đã tải \(total) video" : "\(cached)/\(total) video")
                        .font(.appSans(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextDark)

                    if videoCache.isDownloading && videoCache.downloadSpeedMBps > 0 {
                        Text(String(format: "%.1f MB/s", videoCache.downloadSpeedMBps))
                            .font(.appSans(size: 12, weight: .medium))
                            .foregroundStyle(themeStore.primaryColor)
                    }
                }
                if !allComplete {
                    ProgressBarView(fraction: fraction, color: themeStore.primaryColor, height: 4)
                }
            }

            Spacer(minLength: 4)

            if videoCache.isDownloadingAll {
                // Pause button
                Button {
                    videoCache.pauseAll()
                    Haptics.impact(.medium)
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.appSans(size: 13))
                        .foregroundStyle(themeStore.primaryColor)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            } else if videoCache.isPausedAll {
                // Resume button
                Button {
                    Haptics.impact(.medium)
                    Task { await videoCache.downloadAll() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.appSans(size: 12))
                        Text("Tiếp tục")
                            .font(.appSans(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(themeStore.primaryColor)
                }
            } else if !allComplete {
                Button {
                    Haptics.impact(.medium)
                    Task { await videoCache.downloadAll() }
                } label: {
                    Text("Tải tất cả")
                        .font(.appSans(size: 12, weight: .semibold))
                        .foregroundStyle(themeStore.primaryColor)
                }
            }

            if cached > 0 && !videoCache.isDownloading {
                Text(String(format: "%.0f MB", videoCache.cacheSizeMB))
                    .font(.appSans(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextLight)

                Button { showClearCacheAlert = true } label: {
                    Image(systemName: "trash")
                        .font(.appSans(size: 12))
                        .foregroundStyle(Color.appTextLight)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard()
    }

    // MARK: - Chapter Card with Download

    private func hazardChapterCard(_ chapter: HazardSituation.Chapter) -> some View {
        let chapterScore = progressStore.chapterAverageScore(chapterId: chapter.id)
        let hasPractice = progressStore.chapterHasPractice(chapterId: chapter.id)
        let chCached = videoCache.cachedCount(forChapter: chapter.id)
        let chTotal = videoCache.totalCount(forChapter: chapter.id)
        let chComplete = chCached == chTotal
        let isDownloading = videoCache.downloadingChapters.contains(chapter.id)

        return Button { openExam(.hazardTest(mode: .chapter(chapter.id))) } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(chapter.name)
                        .font(.appSans(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        TagPill(text: "Chương \(chapter.id)")
                        if hasPractice {
                            TagPill(text: "\(Int(chapterScore * 100))% đúng", color: .appPrimary)
                        }
                        TagPill(text: "\(chCached)/\(chTotal) video", color: chComplete ? .appSuccess : nil)
                    }
                }

                Spacer(minLength: 8)

                // Per-chapter download indicator
                chapterDownloadButton(chapterId: chapter.id, cached: chCached, total: chTotal, complete: chComplete, downloading: isDownloading)

                CircularActionButton(icon: "play.fill")
            }
            .padding(metrics.cardPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassCard()
    }

    @ViewBuilder
    private func chapterDownloadButton(chapterId: Int, cached: Int, total: Int, complete: Bool, downloading: Bool) -> some View {
        let isPaused = videoCache.pausedChapters.contains(chapterId)

        Button {
            Haptics.impact(.light)
            if downloading {
                videoCache.pauseChapter(chapterId)
            } else if !complete {
                Task { await videoCache.downloadChapter(chapterId) }
            }
        } label: {
            Group {
                if downloading {
                    Image(systemName: "pause.fill")
                        .font(.appSans(size: 12))
                        .foregroundStyle(themeStore.primaryColor)
                } else if complete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.appSans(size: 15))
                        .foregroundStyle(themeStore.primaryColor)
                } else if isPaused {
                    HStack(spacing: 3) {
                        Image(systemName: "play.fill")
                            .font(.appSans(size: 12))
                        Text("\(cached)/\(total)")
                            .font(.appSans(size: 12, weight: .medium))
                    }
                    .foregroundStyle(themeStore.primaryColor)
                } else {
                    HStack(spacing: 3) {
                        Image(systemName: "icloud.and.arrow.down")
                            .font(.appSans(size: 12))
                        Text("\(cached)/\(total)")
                            .font(.appSans(size: 12, weight: .medium))
                    }
                    .foregroundStyle(themeStore.primaryColor)
                }
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
        .disabled(complete && !downloading)
    }

    // MARK: - Helpers

    private func topicRingColor(accuracy: Double, attempted: Bool) -> Color {
        guard attempted else { return .appPrimary }
        if accuracy >= 0.8 { return .appSuccess }
        if accuracy >= 0.5 { return .appWarning }
        return .appError
    }

    private func chapterIcon(_ id: Int) -> String {
        switch id {
        case 1: return "building.2.fill"
        case 2: return "road.lanes"
        case 3: return "car.rear.road.lane"
        case 4: return "mountain.2.fill"
        case 5: return "car.2.fill"
        case 6: return "exclamationmark.triangle.fill"
        default: return "play.rectangle.fill"
        }
    }
}
