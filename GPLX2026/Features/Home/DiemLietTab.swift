import SwiftUI

struct DiemLietTab: View {
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

        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Practice all button
                Button { openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0)) } label: {
                    AppButton(label: "Ôn tập \(allDiemLiet.count) câu điểm liệt")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .onGeometryChange(for: Bool.self) { proxy in
                    proxy.frame(in: .scrollView(axis: .vertical)).maxY < 60
                } action: { hidden in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showNavPlay = hidden
                    }
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
        .searchable(text: $searchText, prompt: "Tìm câu hỏi...")
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        withAnimation { selectedTopicKey = nil }
                    } label: {
                        Label("Tất cả", systemImage: selectedTopicKey == nil ? "checkmark" : "")
                    }
                    ForEach(byTopic, id: \.topic.id) { entry in
                        Button {
                            withAnimation { selectedTopicKey = entry.topic.key }
                        } label: {
                            Label(
                                "\(entry.topic.shortName) (\(entry.questions.count))",
                                systemImage: selectedTopicKey == entry.topic.key ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    Image(systemName: selectedTopicKey != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}
