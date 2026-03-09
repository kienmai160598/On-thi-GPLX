import SwiftUI

struct BookmarksView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        let allQuestions = questionStore.allQuestions
        let bookmarkIds = progressStore.bookmarks
        let bookmarked = allQuestions.filter { bookmarkIds.contains($0.no) }

        ScrollView {
            if bookmarked.isEmpty {
                EmptyState(icon: "bookmark.slash", message: "Chưa có câu hỏi nào được đánh dấu")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(bookmarked, id: \.no) { question in
                        BookmarkQuestionCard(question: question, topicKey: AppConstants.TopicKey.bookmarks)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !bookmarked.isEmpty {
                Button { openExam(.questionView(topicKey: AppConstants.TopicKey.bookmarks, startIndex: 0)) } label: {
                    AppButton(label: "Luyện tập \(bookmarked.count) câu")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .screenHeader("Đánh dấu")
    }
}

// MARK: - Bookmark Question Card

private struct BookmarkQuestionCard: View {
    @Environment(ProgressStore.self) private var progressStore
    let question: Question
    let topicKey: String

    var body: some View {
        HStack(spacing: 12) {
            NumberBadge(number: question.no, color: .appPrimary)

            Text(question.text)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextDark)
                .lineLimit(2)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)

            Spacer()

            if topicKey == AppConstants.TopicKey.bookmarks {
                Button {
                    progressStore.toggleBookmark(questionNo: question.no)
                } label: {
                    Image(systemName: "bookmark.slash.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextLight)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
    }
}
