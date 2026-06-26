import SwiftUI

// MARK: - ExamTab

struct ExamTab: View {
    @Environment(ProgressStore.self)  private var progressStore
    @Environment(ThemeStore.self)     private var themeStore
    @Environment(LayoutMetrics.self)  private var metrics
    @Environment(\.openExam)          private var openExam

    @State private var filter: ExamSetFilter = .all
    @State private var showAllExamSets = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                // ── Page header ──────────────────────────────────────────
                pageHeader

                // ── Hero feature card (random exam) ──────────────────────
                randomExamCard

                // ── Compact stats strip ──────────────────────────────────
                if !progressStore.examHistory.isEmpty {
                    examStatsCard
                }

                // ── Fixed exam list (filter lives inside) ────────────────
                examListSection
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .glassContainer()
        }
        .screenHeader("Thi thử", titleDisplayMode: .large)
        .tracksTabBarCollapse()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SearchToolbarButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                HistoryToolbarButton { ExamHistoryView() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavPlayButton(label: "Thi thử ngay") {
                    openExam(.mockExam())
                }
            }
        }
    }

    // MARK: - Page Header (subtitle below the native large title)

    private var pageHeader: some View {
        TabPageSubtitle("Kiểm tra kiến thức tổng hợp")
    }

    // MARK: - Random Exam Hero Card (light CTA, mirrors Practice's hero)

    private var randomExamCard: some View {
        let lastResult = progressStore.examHistory.first
        var tags: [String] = [
            "\(LicenseType.current.questionsPerExam) câu",
            "\(LicenseType.current.totalTimeSeconds / 60) phút"
        ]
        if let r = lastResult {
            tags.append("Đạt \(r.score)/\(r.totalQuestions)")
        }
        return LightFeatureCard(
            eyebrow: "Bắt đầu ngay",
            title: "Đề thi mẫu",
            tags: tags,
            icon: "play.fill"
        ) {
            openExam(.mockExam())
        }
    }

    // MARK: - Compact Stats Strip

    private var examStatsCard: some View {
        let totalSets     = LicenseType.current.totalExamSets
        let completedSets = progressStore.completedExamSets
        let attemptCount  = progressStore.examHistory.count
        let passCount     = progressStore.examHistory.filter(\.passed).count
        let passRate      = attemptCount > 0
            ? Int((Double(passCount) / Double(attemptCount) * 100).rounded())
            : 0
        let totalQ        = LicenseType.current.questionsPerExam
        let avgScore      = Int((progressStore.averageExamScore * Double(totalQ)).rounded())

        return HStack(spacing: 0) {
            StatItem(value: "\(completedSets.count)/\(totalSets)", label: "Đề đã thi", valueFontSize: 17)
            Rectangle().fill(Color.appDivider).frame(width: 1, height: 28)
            StatItem(value: "\(passRate)%", label: "Tỉ lệ đạt", valueFontSize: 17)
            Rectangle().fill(Color.appDivider).frame(width: 1, height: 28)
            StatItem(value: "\(avgScore)/\(totalQ)", label: "Điểm TB", valueFontSize: 17)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .glassCard()
    }

    // MARK: - Exam List Section

    private var examListSection: some View {
        let totalSets     = LicenseType.current.totalExamSets
        let completedSets = progressStore.completedExamSets
        let visibleCount  = showAllExamSets ? totalSets : min(6, totalSets)

        let allIds: [Int] = totalSets > 0 ? Array(1...totalSets) : []
        let filteredIds: [Int] = allIds.filter { id in
            switch filter {
            case .all:       return true
            case .attempted: return completedSets.contains(id)
            case .notTried:  return !completedSets.contains(id)
            }
        }
        let displayedIds = Array(filteredIds.prefix(visibleCount))

        return VStack(alignment: .leading, spacing: 12) {
            // Section header (shared component) + count badge
            ContentSectionHeader("Đề thi cố định", badge: "\(filteredIds.count) đề")

            // Filter chips (scoped to this section)
            PillFilterBar(
                items: ExamSetFilter.allCases,
                label: \.rawValue,
                selection: $filter,
                style: .compact,
                scrollable: false
            ) { _ in
                withAnimation(.easeOut(duration: 0.2)) { showAllExamSets = false }
            }

            if displayedIds.isEmpty {
                EmptyState(
                    icon: "doc.text",
                    message: "Chưa có đề thi nào trong mục này."
                )
                .padding(.vertical, 16)
            } else {
                // Exam rows card
                VStack(spacing: 0) {
                    ForEach(Array(displayedIds.enumerated()), id: \.element) { idx, setId in
                        let isCompleted = completedSets.contains(setId)
                        let latestResult = isCompleted ? progressStore.latestResult(forExamSet: setId) : nil
                        ExamListRow(
                            examName: "Đề \(setId)",
                            latestResult: latestResult,
                            isCompleted: isCompleted
                        ) {
                            openExam(.mockExam(examSetId: setId))
                        }
                        if idx < displayedIds.count - 1 {
                            Rectangle()
                                .fill(Color(hex: 0x000000, opacity: 0.051))
                                .frame(height: 1)
                        }
                    }
                }
                .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                // "Show all" button
                if !showAllExamSets && filteredIds.count > visibleCount {
                    Button {
                        withAnimation(.easeOut(duration: 0.25)) { showAllExamSets = true }
                    } label: {
                        Text("Xem tất cả \(filteredIds.count) đề")
                            .font(.appSans(size: 14, weight: .semibold))
                            .foregroundStyle(themeStore.primaryColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

}
