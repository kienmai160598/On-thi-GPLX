import SwiftUI

struct CriticalQuestionsTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"

    @State private var selectedTopicKey: String? = nil
    @State private var showNavPlay = false
    @State private var searchText = ""

    var body: some View {
        let allDiemLiet = questionStore.diemLietQuestions
        let byTopic = questionStore.diemLietByTopic
        let topicProgressCache: [String: [Int: Bool]] = {
            var cache: [String: [Int: Bool]] = [:]
            for q in allDiemLiet {
                let key = Topic.keyForTopicId(q.topic)
                if cache[key] == nil {
                    cache[key] = progressStore.topicProgress(for: key)
                }
            }
            return cache
        }()

        let displayQuestions: [Question] = {
            var questions = allDiemLiet
            if let key = selectedTopicKey {
                questions = questions.filter { Topic.keyForTopicId($0.topic) == key }
            }
            if !searchText.isEmpty {
                questions = questions.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
            }
            return questions
        }()

        let correctCount = allDiemLiet.filter { q in
            let key = Topic.keyForTopicId(q.topic)
            return topicProgressCache[key]?[q.no] == true
        }.count

        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Hero
                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        ProgressRing(
                            current: correctCount,
                            total: allDiemLiet.count,
                            size: 80
                        )

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("Câu hỏi điểm liệt")
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundStyle(Color.appTextDark)

                            Text("Sai 1 câu là trượt, hãy nắm vững!")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextMedium)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    Button { openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0)) } label: {
                        AppButton(label: "Ôn tập \(allDiemLiet.count) câu điểm liệt")
                    }
                    .buttonStyle(.plain)
                    .onGeometryChange(for: Bool.self) { proxy in
                        proxy.frame(in: .scrollView(axis: .vertical)).maxY < 60
                    } action: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }
                }
                .padding(20)
                .glassCard()
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // MARK: - Topic filter chips
                if byTopic.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "Tất cả (\(allDiemLiet.count))", isSelected: selectedTopicKey == nil) {
                                withAnimation { selectedTopicKey = nil }
                            }
                            ForEach(byTopic, id: \.topic.id) { entry in
                                FilterChip(
                                    label: "\(entry.topic.shortName) (\(entry.questions.count))",
                                    isSelected: selectedTopicKey == entry.topic.key
                                ) {
                                    withAnimation { selectedTopicKey = entry.topic.key }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 14)
                }

                // MARK: - Review rows
                LazyVStack(spacing: 8) {
                    ForEach(displayQuestions, id: \.no) { question in
                        let topicKey = Topic.keyForTopicId(question.topic)
                        let answerStatus: AnswerStatus = {
                            guard let result = topicProgressCache[topicKey]?[question.no] else { return .unanswered }
                            return result ? .correct : .wrong
                        }()

                        QuestionReviewRow(question: question, status: answerStatus)
                            .glassCard()
                    }
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 20)
            }
        }
        .searchable(
            text: $searchText,
            prompt: selectedTopicKey != nil
                ? "Tìm trong \(byTopic.first(where: { $0.topic.key == selectedTopicKey })?.topic.shortName ?? "chủ đề")..."
                : "Tìm câu hỏi..."
        )
        .screenHeader("Điểm liệt")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button { openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0)) } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }
}