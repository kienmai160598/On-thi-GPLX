import SwiftUI

// MARK: - HomeTab

struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Chào buổi sáng!"
        case 12..<18: return "Chào buổi chiều!"
        default: return "Chào buổi tối!"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProgressOverview()
                PrimaryActionCard()
                QuickActionsGrid()
                ShortcutsRow()
                RecentResultsCard()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .glassContainer()
        .screenHeader(greetingText)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: QuestionSearchView()) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.appTextDark)
                    }
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.appTextDark)
                    }
                }
            }
        }
    }
}

// MARK: - Progress Overview (compact hero)

private struct ProgressOverview: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let status = progressStore.readinessStatus(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )
        let mastery = status.totalQuestions > 0
            ? Double(status.totalCorrect) / Double(status.totalQuestions)
            : 0
        let streak = progressStore.streakCount
        let daysUntilExam = progressStore.daysUntilExam
        let today = progressStore.todayProgress
        let wrongCount = progressStore.wrongAnswers.count
        let dlDone = status.diemLiet.correct == status.diemLiet.total && status.diemLiet.total > 0

        HStack(spacing: 20) {
            // Ring left
            TopicProgressRing(fraction: mastery, color: .appPrimary, size: 110)

            // Stats right
            VStack(alignment: .leading, spacing: 12) {
                // Caption + badges
                HStack(spacing: 6) {
                    Text("\(status.totalCorrect)/\(status.totalQuestions) câu đúng")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.appTextDark)

                    Spacer(minLength: 0)

                    if streak > 0 {
                        Label("\(streak)", systemImage: "flame.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.appPrimary)
                    }
                    if let days = daysUntilExam {
                        Label(days <= 0 ? "!" : "\(days)d", systemImage: "calendar")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.appPrimary)
                    }
                }

                // Stat rows
                statRow(
                    icon: "exclamationmark.triangle.fill",
                    label: "Điểm liệt",
                    value: "\(status.diemLiet.correct)/\(status.diemLiet.total)",
                    color: dlDone ? .appSuccess : .appWarning
                )
                statRow(
                    icon: "target",
                    label: "Hôm nay",
                    value: "\(today.done)/\(today.goal)",
                    color: today.done >= today.goal ? .appSuccess : .appPrimary
                )
                statRow(
                    icon: "xmark.circle.fill",
                    label: "Câu sai",
                    value: "\(wrongCount)",
                    color: wrongCount > 0 ? .appError : .appTextMedium
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .glassCard()
    }

    private func statRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .bold).monospacedDigit())
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
    }
}

// MARK: - Primary Action (continue learning OR smart nudge)

private struct PrimaryActionCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        if let topicKey = progressStore.lastTopicKey, !topicKey.isEmpty {
            continueCard(topicKey: topicKey)
        } else {
            nudgeCard
        }
    }

    @ViewBuilder
    private func continueCard(topicKey: String) -> some View {
        let index = progressStore.lastQuestionIndex
        let topicName: String = {
            switch topicKey {
            case AppConstants.TopicKey.diemLiet: return "Câu điểm liệt"
            case AppConstants.TopicKey.allQuestions: return "Tất cả câu hỏi"
            case AppConstants.TopicKey.bookmarks: return "Đánh dấu"
            case AppConstants.TopicKey.wrongAnswers: return "Câu sai"
            default: return questionStore.topic(forKey: topicKey)?.name ?? topicKey
            }
        }()

        Button {
            openExam(.questionView(topicKey: topicKey, startIndex: index))
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.appPrimary)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Tiếp tục học")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Text("\(topicName) · Câu \(index + 1)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextLight)
            }
            .padding(12)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var nudgeCard: some View {
        let nudge = progressStore.smartNudge(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )

        Button { handleNudgeTap(nudge) } label: {
            HStack(spacing: 14) {
                Image(systemName: nudge.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.appPrimary)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 48, height: 48)
                    .background(Color.appPrimary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Gợi ý cho bạn")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                    Text(nudge.label)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextLight)
            }
            .padding(12)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    private func handleNudgeTap(_ nudge: ProgressStore.SmartNudge) {
        switch nudge {
        case .masterDiemLiet:
            openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
        case .weakTopic(_, let key, _), .improveTopic(_, let key, _):
            openExam(.questionView(topicKey: key, startIndex: 0))
        case .takeExam, .testWeakestPart, .examReady:
            openExam(.mockExam())
        case .startSimulation:
            let topic6Key = questionStore.topics.first { $0.topicIds.contains(6) }?.key ?? "6"
            openExam(.questionView(topicKey: topic6Key, startIndex: 0))
        case .startHazard:
            openExam(.hazardTest(mode: .practice))
        }
    }
}

// MARK: - Quick Actions (2x2 grid)

private struct QuickActionsGrid: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            HomeActionCard(
                icon: "book.fill",
                title: "Ôn câu hỏi",
                color: .appPrimary
            ) {
                openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
            }

            HomeActionCard(
                icon: "list.clipboard.fill",
                title: "Thi thử",
                color: .appPrimary
            ) {
                openExam(.mockExam())
            }

            HomeActionCard(
                icon: "exclamationmark.triangle.fill",
                title: "Điểm liệt",
                color: .appPrimary
            ) {
                openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
            }

            NavigationLink(destination: WrongAnswersView()) {
                VStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.appPrimary)

                    Text("Câu sai")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 110)
                .glassCard()
            }
            .buttonStyle(.plain)
        }
    }
}

private struct HomeActionCard: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(color)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .semibold).monospacedDigit())
                        .foregroundStyle(color)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shortcuts Row (Đã lưu)

private struct ShortcutsRow: View {
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let bookmarkCount = progressStore.bookmarks.count

        NavigationLink(destination: BookmarksView()) {
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(bookmarkCount > 0 ? Color.appPrimary : Color.appTextLight)

                Text("Đã lưu")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)

                Spacer()

                if bookmarkCount > 0 {
                    Text("\(bookmarkCount)")
                        .font(.system(size: 14, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.appPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Results

private struct RecentResultsCard: View {
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let lastExam = progressStore.examHistory.first
        let lastSim = progressStore.simulationHistory.first
        let lastHazard = progressStore.hazardHistory.first

        if lastExam != nil || lastSim != nil || lastHazard != nil {
            VStack(alignment: .leading, spacing: 14) {
                Text("Kết quả gần đây")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)

                VStack(spacing: 0) {
                    if let exam = lastExam {
                        NavigationLink(destination: ExamHistoryDetailView(result: exam)) {
                            RecentResultRow(
                                title: "Thi thử",
                                score: "\(exam.score)/\(exam.totalQuestions)",
                                passed: exam.passed, date: exam.date
                            )
                        }
                        .buttonStyle(.plain)

                        if lastSim != nil || lastHazard != nil {
                            Divider().padding(.horizontal, 16)
                        }
                    }

                    if let sim = lastSim {
                        NavigationLink(destination: SimulationHistoryDetailView(result: sim)) {
                            RecentResultRow(
                                title: "Mô phỏng",
                                score: "\(sim.score)/\(sim.totalScenarios)",
                                passed: sim.passed, date: sim.date
                            )
                        }
                        .buttonStyle(.plain)

                        if lastHazard != nil {
                            Divider().padding(.horizontal, 16)
                        }
                    }

                    if let hazard = lastHazard {
                        NavigationLink(destination: HazardHistoryDetailView(result: hazard)) {
                            RecentResultRow(
                                title: "Tình huống",
                                score: "\(hazard.totalScore)/\(hazard.maxScore)",
                                passed: hazard.passed, date: hazard.date
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .glassCard()
            }
        }
    }
}

private struct RecentResultRow: View {
    let title: String
    let score: String
    let passed: Bool
    let date: Date

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM HH:mm"
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.appPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                Text(Self.dateFormatter.string(from: date))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextLight)
            }

            Spacer(minLength: 4)

            Text(score)
                .font(.system(size: 16, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.appTextDark)

            StatusBadge(
                text: passed ? "Đạt" : "Trượt",
                color: .appPrimary,
                fontSize: 12
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
