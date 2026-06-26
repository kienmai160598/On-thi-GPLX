import SwiftUI

/// The "Mô phỏng" tab (design YPqmZ): a progress hero with streak + continue,
/// chapter filter chips, a dark "GỢI Ý HÔM NAY" focus card, then the per-chapter
/// cards with colored badges and gold play buttons.
struct MoPhongTab: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.openExam) private var openExam

    @State private var selectedFilter: ChapterFilter = .all
    @AppStorage("hazardDeprecationSeen") private var deprecationSeen = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                heroCard
                PillFilterBar(items: ChapterFilter.allCases, label: \.label, selection: $selectedFilter)
                chapterSection
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .glassContainer()
        }
        .screenHeader("Mô phỏng", titleDisplayMode: .large)
        .onAppear { videoCache.ensureStatsLoaded() }
        .tracksTabBarCollapse()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SearchToolbarButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                HistoryToolbarButton { HazardHistoryView() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavPlayButton(label: "Thi thử mô phỏng") {
                    openExam(.hazardTest(mode: .exam))
                }
            }
        }
        .overlay {
            if !deprecationSeen {
                HazardDeprecationModal(
                    onAcknowledge: { dismissDeprecation() },
                    onContinue: { dismissDeprecation() }
                )
                .transition(.opacity)
            }
        }
    }

    private func dismissDeprecation() {
        withAnimation(.easeOut(duration: 0.25)) { deprecationSeen = true }
    }

    // MARK: - Progress Hero

    private var heroCard: some View {
        let total = videoCache.totalCount
        let practiced = progressStore.hazardPracticedCount
        let pct = total > 0 ? Int(Double(practiced) / Double(total) * 100) : 0
        let streak = progressStore.streakCount

        return VStack(spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TIẾN ĐỘ CỦA BẠN")
                        .font(.appSans(size: 10, weight: .heavy))
                        .tracking(1.2)
                        .foregroundStyle(Color.appTextMedium)

                    HStack(alignment: .bottom, spacing: 6) {
                        Text("\(practiced)")
                            .font(.appSans(size: 34, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                            .monospacedDigit()
                        Text("/ \(total) tình huống")
                            .font(.appSans(size: 13, weight: .semibold))
                            .foregroundStyle(Color.appTextMedium)
                            .padding(.bottom, 4)
                    }
                }

                Spacer()

                Text("\(pct)%")
                    .font(.appSans(size: 13, weight: .heavy))
                    .foregroundStyle(themeStore.primaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeStore.primaryColor.opacity(0.14), in: Capsule())
            }

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.appSans(size: 13, weight: .bold))
                        .foregroundStyle(Color(hex: 0xE5523F))
                    Text("\(streak) ngày liên tiếp")
                        .font(.appSans(size: 12, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                }

                Spacer()

                Button {
                    Haptics.impact(.medium)
                    openExam(.hazardTest(mode: .exam))
                } label: {
                    HStack(spacing: 6) {
                        Text("Tiếp tục")
                            .font(.appSans(size: 12, weight: .bold))
                        Image(systemName: "play.fill")
                            .font(.appSans(size: 11, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 7)
                    .padding(.leading, 14)
                    .padding(.trailing, 12)
                    .background(Color.adaptive(light: 0x0F0F12, dark: 0x57534E), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 22)
    }

    // MARK: - Chapter Section

    private var chapterSection: some View {
        let visible = filteredChapters

        return VStack(alignment: .leading, spacing: 14) {
            ContentSectionHeader("Theo chương")

            if visible.isEmpty {
                EmptyState(icon: "tray", message: "Không có chương nào phù hợp")
            } else {
                VStack(spacing: 10) {
                    ForEach(visible, id: \.id) { chapter in
                        chapterCard(chapter)
                    }
                }
            }
        }
    }

    // MARK: - Chapter Card (colored badge + gold play, design YPqmZ)

    private func chapterCard(_ chapter: HazardSituation.Chapter) -> some View {
        let score = progressStore.chapterAverageScore(chapterId: chapter.id)
        let hasPractice = progressStore.chapterHasPractice(chapterId: chapter.id)
        let cached = videoCache.cachedCount(forChapter: chapter.id)
        let total = videoCache.totalCount(forChapter: chapter.id)

        return Button {
            openExam(.hazardTest(mode: .chapter(chapter.id)))
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CHƯƠNG \(chapter.id)")
                        .font(.appSans(size: 10, weight: .heavy))
                        .tracking(1.0)
                        .foregroundStyle(Color.appTextMedium)

                    Text(chapter.name)
                        .font(.appSans(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 6) {
                        CountPill("\(total) video")
                        AccuracyPill(accuracy: hasPractice ? score : nil)

                        if total > 0 && cached == total {
                            Text("Đã tải")
                                .font(.appSans(size: 11.5, weight: .bold))
                                .foregroundStyle(Color(hex: 0x1F5A2A))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Color(hex: 0xD9F0DA), in: Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                goldPlayButton
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var goldPlayButton: some View {
        Image(systemName: "play.fill")
            .font(.appSans(size: 17, weight: .bold))
            .foregroundStyle(themeStore.primaryColor)
            .frame(width: 44, height: 44)
            .background(Color.neutralWash, in: Circle())
    }

    // MARK: - Filter Logic

    private var filteredChapters: [HazardSituation.Chapter] {
        switch selectedFilter {
        case .all:
            return HazardSituation.chapters
        case .notDone:
            return HazardSituation.chapters.filter { !progressStore.chapterHasPractice(chapterId: $0.id) }
        case .wrong:
            return HazardSituation.chapters.filter { chapter in
                progressStore.chapterHasPractice(chapterId: chapter.id) &&
                progressStore.chapterAverageScore(chapterId: chapter.id) < 0.8
            }
        case .done:
            return HazardSituation.chapters.filter { chapter in
                progressStore.chapterHasPractice(chapterId: chapter.id) &&
                progressStore.chapterAverageScore(chapterId: chapter.id) >= 0.8
            }
        }
    }
}

// MARK: - ChapterFilter

enum ChapterFilter: CaseIterable {
    case all, notDone, wrong, done

    var label: String {
        switch self {
        case .all:     return "Tất cả"
        case .notDone: return "Chưa làm"
        case .wrong:   return "Sai"
        case .done:    return "Đã xong"
        }
    }
}
