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
    @Environment(\.openExam) private var openExam
    @State private var filter: ExamFilter = .all
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
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .glassContainer()
        .screenHeader("Thi thử")
    }

    // MARK: - Question Exam Content

    @ViewBuilder
    private var questionExamContent: some View {
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
        let visibleSets = showAllExamSets ? LicenseType.current.totalExamSets : 6

        VStack(spacing: 0) {
            Button {
                withAnimation(.easeOut(duration: 0.25)) {
                    showAllExamSets.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("ĐỀ THI CỐ ĐỊNH")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.appTextMedium)
                        .tracking(0.5)

                    if completedCount > 0 {
                        Text("\(completedCount)/\(LicenseType.current.totalExamSets)")
                            .font(.system(size: 12, weight: .semibold).monospacedDigit())
                            .foregroundStyle(themeStore.primaryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(themeStore.primaryColor.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    Image(systemName: showAllExamSets ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider().padding(.horizontal, 16)

            ForEach(1...visibleSets, id: \.self) { setId in
                let isCompleted = completedSets.contains(setId)
                let latestResult = isCompleted ? progressStore.latestResult(forExamSet: setId) : nil

                Button { openExam(.mockExam(examSetId: setId)) } label: {
                    HStack(spacing: 12) {
                        Text("Đề \(setId)")
                            .font(.system(size: 16, weight: .semibold).monospacedDigit())
                            .foregroundStyle(Color.appTextDark)

                        Spacer()

                        if let result = latestResult {
                            Text("\(result.score)/\(result.totalQuestions)")
                                .font(.system(size: 14, weight: .medium).monospacedDigit())
                                .foregroundStyle(themeStore.primaryColor)
                        }

                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(themeStore.primaryColor)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if setId < visibleSets {
                    Divider().padding(.horizontal, 16)
                }
            }

            if !showAllExamSets {
                Divider().padding(.horizontal, 16)
                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showAllExamSets = true
                    }
                } label: {
                    Text("Xem tất cả \(LicenseType.current.totalExamSets) đề")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(themeStore.primaryColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .glassCard()
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
                    .font(.system(size: 22))
                    .foregroundStyle(themeStore.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(themeStore.primaryColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.appTextDark)

                    Text(rules)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                }

                Spacer(minLength: 4)
            }

            // Tip
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(themeStore.primaryColor)
                Text(tip)
                    .font(.system(size: 13))
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
        .glassCard()
    }
}
