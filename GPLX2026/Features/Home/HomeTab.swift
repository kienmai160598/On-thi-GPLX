import SwiftUI

// MARK: - HomeTab

struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressHeroCard()
                QuickActionsGrid()
                TopicProgressSection()
                RecentResultsCard()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .screenHeader("Trang chủ")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: BadgesView()) {
                    Image(systemName: "trophy")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }
}

// MARK: - Progress Hero Card

private struct ProgressHeroCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let status = progressStore.readinessStatus(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )
        let totalCorrect = status.totalCorrect
        let totalQuestions = status.totalQuestions
        let mastery = totalQuestions > 0 ? Double(totalCorrect) / Double(totalQuestions) : 0
        let streak = progressStore.streakCount

        let statusColor: Color = switch status.level {
        case .ready: .appSuccess
        case .needsWork: .appWarning
        case .notReady: .appError
        }
        let statusText: String = switch status.level {
        case .ready: "Sẵn sàng thi"
        case .needsWork: "Cần ôn thêm"
        case .notReady: "Chưa sẵn sàng"
        }

        VStack(spacing: 20) {
            // Greeting + Streak
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)

                    Text(statusText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(statusColor)
                }

                Spacer()

                if streak > 0 {
                    VStack(spacing: 2) {
                        Text("\(streak)")
                            .font(.system(size: 22, weight: .heavy).monospacedDigit())
                            .foregroundStyle(Color(hex: 0xFF6B35))
                        Text("ngày")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: 0xFF6B35).opacity(0.7))
                    }
                    .frame(width: 56, height: 56)
                    .background(Color(hex: 0xFF6B35).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            // Big Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 10)

                Circle()
                    .trim(from: 0, to: mastery)
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.8, bounce: 0.15), value: mastery)

                VStack(spacing: 2) {
                    Text("\(Int(mastery * 100))")
                        .font(.system(size: 44, weight: .heavy).monospacedDigit())
                        .foregroundStyle(Color.appTextDark)
                        .contentTransition(.numericText())
                    Text("phần trăm")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                }
            }
            .frame(width: 140, height: 140)

            Text("\(totalCorrect)/\(totalQuestions) câu đã đúng")
                .font(.system(size: 15, weight: .medium).monospacedDigit())
                .foregroundStyle(Color.appTextMedium)

            // Key Stats
            HStack(spacing: 0) {
                MiniStat(
                    value: "\(status.diemLiet.correct)/\(status.diemLiet.total)",
                    label: "Điểm liệt",
                    color: status.diemLiet.correct == status.diemLiet.total && status.diemLiet.total > 0 ? .appSuccess : .appError
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 32)

                MiniStat(
                    value: progressStore.examHistory.isEmpty ? "--" : "\(Int(status.passRate * 100))%",
                    label: "Tỉ lệ đậu",
                    color: status.passRate >= 0.8 ? .appSuccess : .appTextMedium
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 32)

                MiniStat(
                    value: "\(progressStore.examCount)",
                    label: "Lần thi",
                    color: .appTextDark
                )
            }
        }
        .padding(24)
        .glassCard()
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Chào buổi sáng!"
        case 12..<18: return "Chào buổi chiều!"
        default: return "Chào buổi tối!"
        }
    }
}

private struct MiniStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .bold).monospacedDigit())
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .animation(.snappy, value: value)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Actions Grid

private struct QuickActionsGrid: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        let config = resolveAction()
        let dlMastery = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let wrongCount = progressStore.wrongAnswers.count

        LazyVGrid(columns: columns, spacing: 12) {
            QuickActionCard(
                icon: config.icon,
                title: config.title,
                subtitle: config.subtitle,
                color: .appPrimary
            ) {
                openExam(.questionView(topicKey: config.topicKey, startIndex: config.startIndex))
            }

            QuickActionCard(
                icon: "doc.text.fill",
                title: "Thi thử",
                subtitle: "35 câu / 25 phút",
                color: .topicQuyDinh
            ) {
                openExam(.mockExam())
            }

            QuickActionCard(
                icon: "exclamationmark.triangle.fill",
                title: "Điểm liệt",
                subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                color: dlMastery.correct == dlMastery.total && dlMastery.total > 0 ? .appSuccess : .appError
            ) {
                openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
            }

            QuickActionCard(
                icon: "arrow.counterclockwise",
                title: "Ôn câu sai",
                subtitle: wrongCount > 0 ? "\(wrongCount) câu" : "Chưa có",
                color: wrongCount > 0 ? .appWarning : .appTextLight
            ) {
                openExam(.questionView(topicKey: AppConstants.TopicKey.wrongAnswers, startIndex: 0))
            }
        }
    }

    private struct ActionConfig {
        let icon: String; let title: String; let subtitle: String
        let topicKey: String; let startIndex: Int
    }

    private func resolveAction() -> ActionConfig {
        if let topicKey = progressStore.lastTopicKey {
            let topicName = questionStore.topic(forKey: topicKey)?.name ?? "Ôn tập"
            let index = progressStore.lastQuestionIndex
            return ActionConfig(icon: "play.circle.fill", title: "Tiếp tục", subtitle: "Câu \(index + 1) · \(topicName)", topicKey: topicKey, startIndex: index)
        }
        return ActionConfig(icon: "text.book.closed.fill", title: "Bắt đầu học", subtitle: "\(questionStore.allQuestions.count) câu", topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0)
    }
}

private struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Topic Progress Section

private struct TopicProgressSection: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let topicStats = progressStore.weakTopics(topics: questionStore.topics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }

        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Chủ đề")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)
                Spacer()
                NavigationLink(destination: WeakTopicsView()) {
                    Text("Phân tích")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                }
            }

            ForEach(topicStats, id: \.topic.id) { item in
                NavigationLink(destination: TopicDetailView(item: item)) {
                    topicRow(item: item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func topicRow(item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)) -> some View {
        let statusInfo = topicStatus(item)
        let fraction = item.total > 0 ? Double(item.correct) / Double(item.total) : 0

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(statusInfo.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: item.topic.sfSymbol)
                    .font(.system(size: 18))
                    .foregroundStyle(statusInfo.color)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 5) {
                Text(item.topic.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("\(item.correct)/\(item.total)")
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                        .foregroundStyle(statusInfo.color)
                    Text("câu đúng")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextLight)
                }
            }

            Spacer(minLength: 4)

            StatusBadge(text: statusInfo.label, color: statusInfo.color, fontSize: 11)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextLight)
        }
        .padding(16)
        .glassCard()
    }

    private func topicStatus(_ item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)) -> (label: String, color: Color) {
        if item.attempted == 0 {
            return ("Chưa học", .appTextLight)
        } else if item.accuracy >= 0.8 {
            return ("Tốt", .appSuccess)
        } else if item.accuracy >= 0.5 {
            return ("Cần ôn", .appWarning)
        } else {
            return ("Yếu", .appError)
        }
    }
}

// MARK: - Recent Results Card

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
                                icon: "doc.text", title: "Thi thử",
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
                                icon: "play.rectangle", title: "Mô phỏng",
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
                                icon: "play.rectangle.fill", title: "Tình huống",
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
    let icon: String
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
                .foregroundStyle(passed ? Color.appSuccess : Color.appError)

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
                color: passed ? .appSuccess : .appError,
                fontSize: 11
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
