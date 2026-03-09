import SwiftUI

struct SimulationTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

    /// Topic 6 (Sa hình)
    private var saHinhTopic: Topic? {
        questionStore.topics.first { $0.topicIds.contains(6) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Study Section
                studyContent

                // MARK: - Exam Section
                examContent
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .screenHeader("Mô phỏng")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button {
                        openExam(.simulationExam(mode: .random))
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }

    // MARK: - Study Content

    @ViewBuilder
    private var studyContent: some View {
        if let topic = saHinhTopic {
            let progress = progressStore.topicProgress(for: topic.key)
            let correctCount = progress.values.filter { $0 }.count
            let totalCount = topic.questionCount
            let percentage = totalCount > 0 ? Int(Double(correctCount) / Double(totalCount) * 100) : 0

            SectionTitle(title: "Ôn tập")

            // Topic 6 card
            NavigationLink(destination: TopicsView(initialTopicKey: topic.key)) {
                HStack(spacing: 14) {
                    IconBox(
                        icon: topic.icon,
                        color: topic.color,
                        size: 44,
                        cornerRadius: 11,
                        iconFontSize: 20
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text("\(correctCount)/\(totalCount)")
                                .font(.system(size: 13, weight: .semibold).monospacedDigit())
                                .foregroundStyle(percentage >= 80 ? Color.appSuccess : Color.appTextMedium)
                            Text("đúng")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextLight)
                            Text("(\(percentage)%)")
                                .font(.system(size: 13, weight: .medium).monospacedDigit())
                                .foregroundStyle(Color.appTextMedium)
                        }
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .glassCard()

            // Practice all scenarios button
            Button {
                openExam(.questionView(topicKey: topic.key, startIndex: 0))
            } label: {
                ListItemCard(
                    icon: "photo.on.rectangle.angled",
                    title: "Luyện tất cả sa hình",
                    subtitle: "\(totalCount) câu hỏi",
                    iconSize: 40,
                    iconCornerRadius: 10,
                    iconFontSize: 18,
                    iconColor: .topicSaHinh
                ) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Exam Content

    @ViewBuilder
    private var examContent: some View {
        SectionTitle(title: "Thi thử")

        // CTA + Rules
        ExamCTACard(
            buttonLabel: "Thi mô phỏng (20 câu)",
            rules: [
                (icon: "photo.on.rectangle", text: "20 câu"),
                (icon: "timer", text: "60s/câu"),
                (icon: "checkmark.circle", text: "≥ 70%"),
            ],
            tip: "Quan sát kỹ hình ảnh, chú ý biển báo và vạch kẻ đường.",
            action: { openExam(.simulationExam(mode: .random)) },
            onButtonHidden: { hidden in
                withAnimation(.easeInOut(duration: 0.2)) {
                    showNavPlay = hidden
                }
            }
        )

        // Stats
        if !progressStore.simulationHistory.isEmpty {
            ExamStatsRow(items: [
                (value: "\(progressStore.simulationExamCount)", label: "Đã thi"),
                (value: "\(Int(progressStore.averageSimulationScore * 100))%", label: "TB đúng"),
                (value: "\(Int(progressStore.bestSimulationScore * 100))%", label: "Cao nhất"),
            ])
        }

        // History
        if !progressStore.simulationHistory.isEmpty {
            SectionTitle(title: "Lịch sử")

            HistoryList(
                results: progressStore.simulationHistory,
                scoreText: { "\($0.score)/\($0.totalScenarios) đúng" },
                passed: \.passed,
                date: \.date,
                destination: { SimulationHistoryDetailView(result: $0) }
            )
        }
    }
}
