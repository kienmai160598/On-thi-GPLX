import SwiftUI

struct QuestionSearchView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.openExam) private var openExam

    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all

    private enum FilterOption: String, CaseIterable {
        case all = "Tất cả"
        case diemLiet = "Điểm liệt"
        case wrong = "Câu sai"
        case unanswered = "Chưa làm"
    }

    private var filteredQuestions: [Question] {
        var questions: [Question]

        // Text search
        if searchText.isEmpty {
            questions = questionStore.allQuestions
        } else {
            questions = questionStore.allQuestions.filter {
                $0.text.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .diemLiet:
            questions = questions.filter { $0.isDiemLiet }
        case .wrong:
            questions = questions.filter { q in
                let topicKey = Topic.keyForTopicId(q.topic)
                return progressStore.answerStatus(topicKey: topicKey, questionNo: q.no) == .wrong
            }
        case .unanswered:
            questions = questions.filter { q in
                let topicKey = Topic.keyForTopicId(q.topic)
                return progressStore.answerStatus(topicKey: topicKey, questionNo: q.no) == .unanswered
            }
        }

        return questions
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Result count
                if !searchText.isEmpty || selectedFilter != .all {
                    Text("\(filteredQuestions.count) câu hỏi")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                        .padding(.horizontal, 20)
                }

                // Results
                if filteredQuestions.isEmpty {
                    if !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .padding(.top, 40)
                    } else {
                        EmptyState(icon: "tray", message: "Không có câu hỏi")
                    }
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredQuestions, id: \.no) { question in
                            let topicKey = Topic.keyForTopicId(question.topic)
                            let status = progressStore.answerStatus(topicKey: topicKey, questionNo: question.no)

                            QuestionReviewRow(
                                question: question,
                                status: status,
                                showStatusIcon: false,
                                onNavigate: {
                                    let topicQuestions = questionStore.questionsForTopic(key: topicKey)
                                    let idx = topicQuestions.firstIndex(where: { $0.no == question.no }) ?? 0
                                    openExam(.questionView(topicKey: topicKey, startIndex: idx))
                                }
                            )
                            .glassCard()
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .searchable(text: $searchText, prompt: "Tìm câu hỏi...")
        .screenHeader("Tìm kiếm")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(selection: $selectedFilter) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    } label: {}
                } label: {
                    Image(systemName: selectedFilter == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(selectedFilter == .all ? Color.appTextMedium : themeStore.primaryColor)
                }
            }
        }
    }
}
