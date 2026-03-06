import SwiftUI

// MARK: - HomeTab

struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let topicStats = progressStore.weakTopics(topics: questionStore.topics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }

        ScrollView {
            VStack(spacing: 20) {
                OverviewCard()

                ContinueLearningCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Chủ đề")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)

                    topicCards(topicStats)
                }

                RecentResultsCard()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .screenHeader("Trang chủ")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }

    // MARK: - Topic cards

    private func topicCards(_ stats: [(topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)]) -> some View {
        VStack(spacing: 12) {
            ForEach(stats, id: \.topic.id) { item in
                let statusInfo = topicStatus(item)

                NavigationLink(destination: TopicDetailView(item: item)) {
                    HStack(spacing: 14) {
                        IconBox(
                            icon: item.topic.sfSymbol,
                            color: .appPrimary,
                            size: 48,
                            cornerRadius: 12,
                            iconFontSize: 20
                        )

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.topic.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(1)

                                Spacer(minLength: 8)

                                StatusBadge(
                                    text: statusInfo.label,
                                    color: statusInfo.color,
                                    fontSize: 11
                                )
                            }

                            let fraction = item.total > 0 ? Double(item.correct) / Double(item.total) : 0
                            VStack(alignment: .leading, spacing: 4) {
                                ProgressBarView(fraction: fraction, color: statusInfo.color, height: 6)

                                Text("\(item.correct)/\(item.total) câu đúng")
                                    .font(.system(size: 13, weight: .medium).monospacedDigit())
                                    .foregroundStyle(Color.appTextLight)
                            }
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                    .padding(16)
                    .glassCard()
                }
                .buttonStyle(.plain)
            }
        }
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

// MARK: - Continue Learning Card

private struct ContinueLearningCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        let config = resolveAction()

        Button { openExam(.questionView(topicKey: config.topicKey, startIndex: config.startIndex)) } label: {
            HStack(spacing: 14) {
                IconBox(
                    icon: config.icon,
                    color: .appPrimary,
                    size: 48,
                    cornerRadius: 12,
                    iconFontSize: 20
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(config.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Text(config.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                }

                Spacer(minLength: 4)

                Image(systemName: "play.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appPrimary)
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    private struct ActionConfig {
        let icon: String
        let title: String
        let subtitle: String
        let topicKey: String
        let startIndex: Int
    }

    private func resolveAction() -> ActionConfig {
        if let topicKey = progressStore.lastTopicKey {
            let topicName = questionStore.topic(forKey: topicKey)?.name ?? "Ôn tập"
            let index = progressStore.lastQuestionIndex
            return ActionConfig(
                icon: "play.circle.fill",
                title: "Tiếp tục học",
                subtitle: "Câu \(index + 1) · \(topicName)",
                topicKey: topicKey,
                startIndex: index
            )
        }

        if !progressStore.wrongAnswers.isEmpty {
            return ActionConfig(
                icon: "xmark.circle.fill",
                title: "Ôn tập câu sai",
                subtitle: "\(progressStore.wrongAnswers.count) câu cần ôn lại",
                topicKey: AppConstants.TopicKey.wrongAnswers,
                startIndex: 0
            )
        }

        return ActionConfig(
            icon: "text.book.closed.fill",
            title: "Bắt đầu học",
            subtitle: "\(questionStore.allQuestions.count) câu hỏi",
            topicKey: AppConstants.TopicKey.allQuestions,
            startIndex: 0
        )
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
            VStack(alignment: .leading, spacing: 12) {
                Text("Kết quả gần đây")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)

                VStack(spacing: 0) {
                    if let exam = lastExam {
                        NavigationLink(destination: ExamHistoryDetailView(result: exam)) {
                            RecentResultRow(
                                icon: "doc.text",
                                title: "Thi thử",
                                score: "\(exam.score)/\(exam.totalQuestions)",
                                passed: exam.passed,
                                date: exam.date
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
                                icon: "play.rectangle",
                                title: "Mô phỏng",
                                score: "\(sim.score)/\(sim.totalScenarios)",
                                passed: sim.passed,
                                date: sim.date
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
                                icon: "play.rectangle.fill",
                                title: "Tình huống",
                                score: "\(hazard.totalScore)/\(hazard.maxScore)",
                                passed: hazard.passed,
                                date: hazard.date
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
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24)

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
                .font(.system(size: 15, weight: .bold).monospacedDigit())
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

// MARK: - Overview Card

private struct OverviewCard: View {
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
        let statusIcon = status.isReady ? "checkmark.shield.fill" : "exclamationmark.triangle.fill"
        let statusText: String = switch status.level {
        case .ready: "Sẵn sàng thi"
        case .needsWork: "Cần ôn thêm"
        case .notReady: "Chưa sẵn sàng"
        }

        VStack(spacing: 20) {
            // Status + Ring
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.appDivider, lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: mastery)
                        .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(mastery * 100))%")
                        .font(.system(size: 24, weight: .heavy).monospacedDigit())
                        .foregroundStyle(Color.appTextDark)
                }
                .frame(width: 88, height: 88)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: statusIcon)
                            .font(.system(size: 20))
                            .foregroundStyle(statusColor)

                        Text(statusText)
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(statusColor)
                    }

                    Text("\(totalCorrect)/\(totalQuestions) câu đã đúng")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)

                    ProgressBarView(fraction: status.score, color: statusColor, height: 8)
                        .padding(.top, 2)
                }

                Spacer(minLength: 0)
            }

            // Stats row
            HStack(spacing: 0) {
                OverviewDetail(
                    value: "\(status.diemLiet.correct)/\(status.diemLiet.total)",
                    label: "Điểm liệt",
                    color: status.diemLiet.correct == status.diemLiet.total && status.diemLiet.total > 0 ? .appSuccess : .appError
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 28)

                OverviewDetail(
                    value: progressStore.examHistory.isEmpty ? "--" : "\(Int(status.passRate * 100))%",
                    label: "Tỉ lệ đậu",
                    color: status.passRate >= 0.8 ? .appSuccess : .appTextMedium
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 28)

                OverviewDetail(
                    value: "\(streak)",
                    label: "Chuỗi ngày",
                    color: streak > 0 ? Color(hex: 0xFF6B35) : .appTextMedium
                )
            }
        }
        .padding(20)
        .glassCard()
    }
}

private struct OverviewDetail: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold).monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
    }
}
