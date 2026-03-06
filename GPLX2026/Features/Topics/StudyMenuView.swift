import SwiftUI

struct StudyMenuView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        let totalQuestions = questionStore.allQuestions.count
        let dlMastery = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let wrongCount = progressStore.wrongAnswers.count
        let bookmarkCount = progressStore.bookmarks.count

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Tra cứu
                SectionTitle(title: "Tra cứu")
                    .padding(.bottom, 10)

                VStack(spacing: 0) {
                    NavigationLink(destination: TrafficSignsReferenceView()) {
                        StudyRow(
                            icon: "diamond.fill",
                            title: "Biển báo giao thông",
                            subtitle: "47 biển báo phổ biến"
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: SpeedDistanceReferenceView()) {
                        StudyRow(
                            icon: "speedometer",
                            title: "Tốc độ & Quy tắc",
                            subtitle: "Tốc độ, khoảng cách, mức phạt"
                        )
                    }
                }
                .glassCard()
                .padding(.bottom, 24)

                // MARK: - Luyện tập
                SectionTitle(title: "Luyện tập")
                    .padding(.bottom, 10)

                VStack(spacing: 0) {
                    Button { openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0)) } label: {
                        StudyRow(
                            icon: "text.book.closed.fill",
                            title: "Tất cả câu hỏi",
                            subtitle: "\(totalQuestions) câu hỏi theo thứ tự"
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: TopicsView()) {
                        StudyRow(
                            icon: "books.vertical.fill",
                            title: "Học theo chủ đề",
                            subtitle: "5 chủ đề chính"
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: DiemLietTab()) {
                        StudyRow(
                            icon: "exclamationmark.triangle.fill",
                            title: "Câu điểm liệt",
                            subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                            trailing: dlMastery.correct == dlMastery.total && dlMastery.total > 0
                                ? AnyView(StatusBadge(text: "Done", color: .appSuccess, fontSize: 10))
                                : nil
                        )
                    }
                }
                .glassCard()
                .padding(.bottom, 24)

                // MARK: - Ôn tập
                SectionTitle(title: "Ôn tập")
                    .padding(.bottom, 10)

                VStack(spacing: 0) {
                    NavigationLink(destination: WrongAnswersView()) {
                        StudyRow(
                            icon: "xmark.circle",
                            title: "Câu trả lời sai",
                            subtitle: wrongCount > 0 ? "\(wrongCount) câu cần ôn lại" : "Chưa có câu sai"
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: BookmarksView()) {
                        StudyRow(
                            icon: "bookmark.fill",
                            title: "Đã đánh dấu",
                            subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu đã lưu" : "Chưa đánh dấu câu nào"
                        )
                    }
                }
                .glassCard()
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .screenHeader("Ôn tập")
    }
}

// MARK: - Study Row

private struct StudyRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 4)

            if let trailing {
                trailing
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextLight)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

