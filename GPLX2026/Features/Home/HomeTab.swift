import SwiftUI

// MARK: - HomeTab

struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressHeroCard()
                ExamCountdownCard()
                SmartNudgeCard()
                UtilityGrid()
                TopicProgressSection()
                StudyHeatMap()
                RecentResultsCard()
                ReferenceSection()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .glassContainer()
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
        let mastery = Double(status.percentage) / 100.0
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
                    Text("% sẵn sàng")
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

// MARK: - Smart Nudge Card

private struct SmartNudgeCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        let nudge = progressStore.smartNudge(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )

        Button { handleNudgeTap(nudge) } label: {
            HStack(spacing: 14) {
                Image(systemName: nudge.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(nudgeColor(nudge))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 44, height: 44)
                    .background(nudgeColor(nudge).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Tiếp theo")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                        .textCase(.uppercase)
                    Text(nudge.label)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(nudgeColor(nudge))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    private func nudgeColor(_ nudge: ProgressStore.SmartNudge) -> Color {
        switch nudge {
        case .masterDiemLiet: return .appError
        case .weakTopic, .improveTopic: return .appWarning
        case .takeExam, .startHazard, .testWeakestPart: return .appPrimary
        case .startSimulation: return .topicSaHinh
        case .examReady: return .appSuccess
        }
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

// MARK: - Utility Grid

private struct UtilityGrid: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        let dlMastery = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let wrongCount = progressStore.wrongAnswers.count
        let bookmarkCount = progressStore.bookmarks.count

        LazyVGrid(columns: columns, spacing: 12) {
            QuickActionCard(
                icon: "rectangle.on.rectangle.angled",
                title: "Flashcard",
                subtitle: "Lật thẻ ôn nhanh",
                color: .topicSaHinh
            ) {
                openExam(.flashcard(topicKey: AppConstants.TopicKey.allQuestions))
            }

            QuickActionCard(
                icon: "exclamationmark.triangle.fill",
                title: "Điểm liệt",
                subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                color: dlMastery.correct == dlMastery.total && dlMastery.total > 0 ? .appSuccess : .appError
            ) {
                openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
            }

            NavigationLink(destination: WrongAnswersView()) {
                QuickActionCardLabel(
                    icon: "xmark.circle.fill",
                    title: "Câu sai",
                    subtitle: wrongCount > 0 ? "\(wrongCount) câu" : "Chưa có",
                    color: wrongCount > 0 ? .appWarning : .appTextLight
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: BookmarksView()) {
                QuickActionCardLabel(
                    icon: "bookmark.fill",
                    title: "Đã đánh dấu",
                    subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu" : "Chưa có",
                    color: bookmarkCount > 0 ? .topicCauTao : .appTextLight
                )
            }
            .buttonStyle(.plain)
        }
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
                    .symbolRenderingMode(.hierarchical)

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

private struct QuickActionCardLabel: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)

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
                    .symbolRenderingMode(.hierarchical)
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

// MARK: - Reference Section

private struct ReferenceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tra cứu")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            VStack(spacing: 0) {
                NavigationLink(destination: TrafficSignsReferenceView()) {
                    ListItemCard(
                        icon: "diamond.fill",
                        title: "Biển báo giao thông",
                        subtitle: "47 biển báo phổ biến",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: .topicBienBao,
                        showCard: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                }

                Divider().padding(.horizontal, 16)

                NavigationLink(destination: SpeedDistanceReferenceView()) {
                    ListItemCard(
                        icon: "speedometer",
                        title: "Tốc độ & Quy tắc",
                        subtitle: "Tốc độ, khoảng cách, mức phạt",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: .topicSaHinh,
                        showCard: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                }
            }
            .glassCard()
        }
    }
}
