import SwiftUI

private enum ExamFilter: String, CaseIterable {
    case all = "Tất cả"
    case questions = "Câu hỏi"
    case simulation = "Sa hình"
    case hazard = "Tình huống"
}

struct ExamTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.openExam) private var openExam
    @State private var filter: ExamFilter = .all
    @State private var showFixedExams = false
    @State private var showAllExamSets = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ExamFilter.allCases, id: \.self) { item in
                            FilterChip(label: item.rawValue, isSelected: filter == item) {
                                filter = item
                            }
                        }
                    }
                }

                if filter == .all || filter == .questions {
                    questionExamContent
                }
                if filter == .all || filter == .simulation {
                    simulationExamContent
                }
                if filter == .all || filter == .hazard {
                    hazardExamContent
                }
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .glassContainer()
        .screenHeader("Thi thử")
    }

    // MARK: - Question Exam Content

    @ViewBuilder
    private var questionExamContent: some View {
        VStack(spacing: 0) {
            ExamTypeCard(
                icon: "doc.text.fill",
                title: "Thi câu hỏi",
                rules: "\(LicenseType.current.questionsPerExam) câu · \(LicenseType.current.totalTimeSeconds / 60) phút · ≥ \(LicenseType.current.passThreshold) đạt",
                tip: "Sai điểm liệt = Trượt",

                stats: progressStore.examHistory.isEmpty ? nil : (
                    count: progressStore.examCount,
                    avg: Int(progressStore.averageExamScore * 100),
                    best: Int(progressStore.bestExamScore * 100)
                )
            ) {
                openExam(.mockExam())
            }

            fixedExamSets
        }
        .glassCard()

        if !progressStore.examHistory.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Lịch sử câu hỏi")
                HistoryList(
                    results: Array(progressStore.examHistory.prefix(5)),
                    scoreText: { "\($0.score)/\($0.totalQuestions) đúng" },
                    passed: \.passed,
                    date: \.date,
                    destination: { ExamHistoryDetailView(result: $0) }
                )
            }
        }
    }

    // MARK: - Simulation Exam Content

    @ViewBuilder
    private var simulationExamContent: some View {
        ExamTypeCard(
            icon: "photo.on.rectangle.fill",
            title: "Thi sa hình",
            rules: "20 câu · 60s/câu · ≥ 70%",
            tip: "Chú ý biển báo và vạch kẻ đường",

            stats: progressStore.simulationHistory.isEmpty ? nil : (
                count: progressStore.simulationExamCount,
                avg: Int(progressStore.averageSimulationScore * 100),
                best: Int(progressStore.bestSimulationScore * 100)
            )
        ) {
            openExam(.simulationExam(mode: .random))
        }
        .glassCard()

        if !progressStore.simulationHistory.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Lịch sử sa hình")
                HistoryList(
                    results: Array(progressStore.simulationHistory.prefix(5)),
                    scoreText: { "\($0.score)/\($0.totalScenarios) đúng" },
                    passed: \.passed,
                    date: \.date,
                    destination: { SimulationHistoryDetailView(result: $0) }
                )
            }
        }
    }

    // MARK: - Hazard Exam Content

    @ViewBuilder
    private var hazardExamContent: some View {
        ExamTypeCard(
            icon: "play.rectangle.fill",
            title: "Thi tình huống",
            rules: "10 video · Nhấn nhanh · ≥ 35/50",
            tip: "Nhấn sớm khi thấy nguy hiểm",

            stats: progressStore.hazardHistory.isEmpty ? nil : (
                count: progressStore.hazardExamCount,
                avg: Int(progressStore.averageHazardScore * 100),
                best: progressStore.bestHazardScore * 100 / 50
            )
        ) {
            openExam(.hazardTest(mode: .exam))
        }
        .glassCard()

        if !progressStore.hazardHistory.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Lịch sử tình huống")
                HistoryList(
                    results: Array(progressStore.hazardHistory.prefix(5)),
                    scoreText: { "\($0.totalScore)/\($0.maxScore) điểm" },
                    passed: \.passed,
                    date: \.date,
                    destination: { HazardHistoryDetailView(result: $0) }
                )
            }
        }
    }

    // MARK: - Fixed Exam Sets

    @ViewBuilder
    private var fixedExamSets: some View {
        let completedSets = progressStore.completedExamSets
        let completedCount = completedSets.count

        VStack(spacing: 0) {
            Divider().padding(.horizontal, 12)

            // Header toggle
            Button {
                withAnimation(.easeOut(duration: 0.25)) {
                    showFixedExams.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Đề thi cố định")
                        .font(.appSans(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)

                    if completedCount > 0 {
                        Text("\(completedCount)/\(LicenseType.current.totalExamSets)")
                            .font(.appSans(size: 12, weight: .medium))
                            .foregroundStyle(themeStore.primaryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(themeStore.primaryColor.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    Image(systemName: showFixedExams ? "chevron.up" : "chevron.down")
                        .font(.appSans(size: 12, weight: .medium))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expandable exam set list
            if showFixedExams {
                let visibleSets = showAllExamSets ? LicenseType.current.totalExamSets : 6

                Divider().padding(.horizontal, 12)

                ForEach(1...visibleSets, id: \.self) { setId in
                    let isCompleted = completedSets.contains(setId)
                    let latestResult = isCompleted ? progressStore.latestResult(forExamSet: setId) : nil

                    Button { openExam(.mockExam(examSetId: setId)) } label: {
                        HStack(spacing: 12) {
                            Text("Đề \(setId)")
                                .font(.appSans(size: 15, weight: .medium))
                                .foregroundStyle(Color.appTextDark)

                            Spacer()

                            if let result = latestResult {
                                Text("\(result.score)/\(result.totalQuestions)")
                                    .font(.appSans(size: 14, weight: .medium))
                                    .foregroundStyle(themeStore.primaryColor)
                            }

                            if isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.appSans(size: 16))
                                    .foregroundStyle(themeStore.primaryColor)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.appSans(size: 12, weight: .medium))
                                    .foregroundStyle(Color.appTextLight)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 46)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if setId < visibleSets {
                        Divider().padding(.horizontal, 12)
                    }
                }

                if !showAllExamSets {
                    Divider().padding(.horizontal, 12)
                    Button {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showAllExamSets = true
                        }
                    } label: {
                        Text("Xem tất cả \(LicenseType.current.totalExamSets) đề")
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

// MARK: - Exam Type Card

private struct ExamTypeCard: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    let title: String
    let rules: String
    let tip: String
    var stats: (count: Int, avg: Int, best: Int)?
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.appSans(size: 22))
                    .foregroundStyle(themeStore.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(themeStore.primaryColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.appSerif(size: 17, weight: .bold))
                        .foregroundStyle(Color.appTextDark)

                    Text(rules)
                        .font(.appSans(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                }

                Spacer(minLength: 4)
            }

            // Tip
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.appSans(size: 11))
                    .foregroundStyle(themeStore.primaryColor)
                Text(tip)
                    .font(.appSans(size: 13))
                    .foregroundStyle(Color.appTextLight)
            }

            // Stats (if any)
            if let stats {
                HStack(spacing: 0) {
                    StatItem(value: "\(stats.count)", label: "Đã thi", valueFontSize: 15)
                    Rectangle().fill(Color.appDivider).frame(width: 1, height: 24)
                    StatItem(value: "\(stats.avg)%", label: "TB đúng", valueFontSize: 15)
                    Rectangle().fill(Color.appDivider).frame(width: 1, height: 24)
                    StatItem(value: "\(stats.best)%", label: "Cao nhất", valueFontSize: 15)
                }
            }

            // Start button
            Button(action: action) {
                AppButton(icon: "play.fill", label: "Bắt đầu", height: 48)
            }
        }
        .padding(12)
    }
}
