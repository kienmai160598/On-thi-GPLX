import SwiftUI

struct TheoryTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Study Section
                SectionTitle(title: "Ôn tập")

                theoryTopicsList

                allQuestionsButton

                // MARK: - Exam Section
                SectionTitle(title: "Thi thử")

                ExamCTACard(
                    buttonLabel: "Bắt đầu thi thử",
                    rules: [
                        (icon: "questionmark.circle", text: "35 câu"),
                        (icon: "timer", text: "25 phút"),
                        (icon: "checkmark.circle", text: "≥ 32 đạt"),
                    ],
                    tip: "Sai câu điểm liệt = Trượt. Làm câu điểm liệt trước, không bỏ trống câu nào.",
                    action: { openExam(.mockExam()) },
                    onButtonHidden: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }
                )

                if !progressStore.examHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.examCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageExamScore * 100))%", label: "TB đúng"),
                        (value: "\(Int(progressStore.bestExamScore * 100))%", label: "Cao nhất"),
                    ])
                }

                fixedExamSets

                if !progressStore.examHistory.isEmpty {
                    SectionTitle(title: "Lịch sử")

                    HistoryList(
                        results: progressStore.examHistory,
                        scoreText: { "\($0.score)/\($0.totalQuestions) đúng" },
                        passed: \.passed,
                        date: \.date,
                        destination: { ExamHistoryDetailView(result: $0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .screenHeader("Lý thuyết")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button { openExam(.mockExam()) } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }

    // MARK: - Study: Topic cards (Topics 1-5 only)

    @ViewBuilder
    private var theoryTopicsList: some View {
        let theoryTopics = questionStore.topics.filter { !$0.topicIds.contains(6) }
        let topicStats = progressStore.weakTopics(topics: theoryTopics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }

        VStack(spacing: 0) {
            ForEach(Array(topicStats.enumerated()), id: \.element.topic.id) { index, item in
                NavigationLink(destination: TopicDetailView(item: item)) {
                    TheoryTopicRow(item: item)
                }
                .buttonStyle(.plain)

                if index < topicStats.count - 1 {
                    Divider().padding(.horizontal, 16)
                }
            }
        }
        .glassCard()
    }

    // MARK: - Study: All questions button

    @ViewBuilder
    private var allQuestionsButton: some View {
        let theoryTopics = questionStore.topics.filter { !$0.topicIds.contains(6) }
        let theoryCount = theoryTopics.reduce(0) { $0 + $1.questionCount }

        Button {
            openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
        } label: {
            ListItemCard(
                icon: "text.book.closed.fill",
                title: "Tất cả câu hỏi",
                subtitle: "\(theoryCount) câu lý thuyết",
                iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                iconColor: .appPrimary
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .glassCard()
    }

    // MARK: - Exam: Fixed sets (same as old MockExamTab)

    @ViewBuilder
    private var fixedExamSets: some View {
        SectionTitle(title: "Đề thi cố định")

        VStack(spacing: 0) {
            let completedSets = progressStore.completedExamSets

            ForEach(Array(stride(from: 1, through: 20, by: 2)), id: \.self) { rowStart in
                if rowStart > 1 {
                    Divider().padding(.horizontal, 16)
                }

                HStack(spacing: 0) {
                    ForEach([rowStart, rowStart + 1], id: \.self) { setId in
                        if setId > rowStart {
                            Divider().frame(height: 56)
                        }

                        let isCompleted = completedSets.contains(setId)
                        let latestResult = isCompleted ? progressStore.latestResult(forExamSet: setId) : nil

                        Button { openExam(.mockExam(examSetId: setId)) } label: {
                            HStack(spacing: 10) {
                                Text("Đề \(setId)")
                                    .font(.system(size: 15, weight: .semibold).monospacedDigit())
                                    .foregroundStyle(Color.appTextDark)

                                Spacer()

                                if isCompleted {
                                    if let result = latestResult {
                                        Text("\(result.score)/\(result.totalQuestions)")
                                            .font(.system(size: 13, weight: .medium).monospacedDigit())
                                            .foregroundStyle(result.passed ? Color.appSuccess : Color.appError)
                                    }
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.appSuccess)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color.appTextLight)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 56)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .glassCard()
    }
}

// MARK: - Theory Topic Row

private struct TheoryTopicRow: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

    private var statusInfo: (label: String, color: Color) {
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

    var body: some View {
        let fraction = item.total > 0 ? Double(item.correct) / Double(item.total) : 0

        HStack(spacing: 14) {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
