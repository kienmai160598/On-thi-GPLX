import SwiftUI

struct QuestionSearchView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    @State private var searchText = ""

    private var displayQuestions: [Question] {
        if searchText.isEmpty {
            return questionStore.diemLietQuestions
        }
        return questionStore.allQuestions.filter {
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            if !searchText.isEmpty && displayQuestions.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .padding(.top, 60)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if searchText.isEmpty {
                        Text("Câu điểm liệt")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.appTextMedium)
                            .padding(.horizontal, 20)
                    } else {
                        Text("\(displayQuestions.count) kết quả")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.appTextMedium)
                            .padding(.horizontal, 20)
                    }

                    LazyVStack(spacing: 8) {
                        ForEach(displayQuestions, id: \.no) { question in
                            let topicKey = Topic.keyForTopicId(question.topic)
                            let status = progressStore.answerStatus(topicKey: topicKey, questionNo: question.no)

                            QuestionReviewRow(question: question, status: status)
                                .glassCard()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .searchable(text: $searchText, prompt: "Tìm câu hỏi...")
        .screenHeader("Câu hỏi")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Xem tất cả", destination: TopicsView())
            }
        }
    }
}
