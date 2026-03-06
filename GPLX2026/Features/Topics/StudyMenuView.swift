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
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Luyện tập
                SectionTitle(title: "Luyện tập")

                VStack(spacing: 0) {
                    Button { openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0)) } label: {
                        StudyRow(
                            icon: "text.book.closed.fill",
                            title: "Tất cả câu hỏi",
                            subtitle: "\(totalQuestions) câu hỏi theo thứ tự",
                            iconColor: .appPrimary
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: TopicsView()) {
                        StudyRow(
                            icon: "books.vertical.fill",
                            title: "Học theo chủ đề",
                            subtitle: "5 chủ đề chính",
                            iconColor: .topicKyThuat
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: DiemLietTab()) {
                        StudyRow(
                            icon: "exclamationmark.triangle.fill",
                            title: "Câu điểm liệt",
                            subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                            iconColor: .appError,
                            trailing: dlMastery.correct == dlMastery.total && dlMastery.total > 0
                                ? AnyView(StatusBadge(text: "Done", color: .appSuccess, fontSize: 10))
                                : nil
                        )
                    }
                }
                .glassCard()

                // MARK: - Ôn tập
                SectionTitle(title: "Ôn tập")

                VStack(spacing: 0) {
                    NavigationLink(destination: WrongAnswersView()) {
                        StudyRow(
                            icon: "xmark.circle.fill",
                            title: "Câu trả lời sai",
                            subtitle: wrongCount > 0 ? "\(wrongCount) câu cần ôn lại" : "Chưa có câu sai",
                            iconColor: wrongCount > 0 ? .appWarning : .appTextLight
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: BookmarksView()) {
                        StudyRow(
                            icon: "bookmark.fill",
                            title: "Đã đánh dấu",
                            subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu đã lưu" : "Chưa đánh dấu câu nào",
                            iconColor: bookmarkCount > 0 ? .topicCauTao : .appTextLight
                        )
                    }
                }
                .glassCard()

                // MARK: - Tra cứu
                SectionTitle(title: "Tra cứu")

                VStack(spacing: 0) {
                    NavigationLink(destination: TrafficSignsReferenceView()) {
                        StudyRow(
                            icon: "diamond.fill",
                            title: "Biển báo giao thông",
                            subtitle: "47 biển báo phổ biến",
                            iconColor: .topicBienBao
                        )
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: SpeedDistanceReferenceView()) {
                        StudyRow(
                            icon: "speedometer",
                            title: "Tốc độ & Quy tắc",
                            subtitle: "Tốc độ, khoảng cách, mức phạt",
                            iconColor: .topicSaHinh
                        )
                    }
                }
                .glassCard()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .screenHeader("Ôn tập")
    }
}

// MARK: - Study Row

private struct StudyRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = .appPrimary
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: 14) {
            IconBox(icon: icon, color: iconColor, size: 40, cornerRadius: 10, iconFontSize: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
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
