import SwiftUI

struct StudyMenuView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"

    var body: some View {
        let totalQuestions = questionStore.allQuestions.count
        let dlMastery = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let wrongCount = progressStore.wrongAnswers.count
        let bookmarkCount = progressStore.bookmarks.count

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Tra cứu
                SectionTitle(title: "Tra cứu")
                    .padding(.bottom, 8)

                NavigationLink(destination: TrafficSignsReferenceView()) {
                    StudyRow(
                        icon: "diamond.fill",
                        iconColor: .appPrimary,
                        title: "Biển báo giao thông",
                        subtitle: "47 biển báo phổ biến"
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)

                NavigationLink(destination: SpeedDistanceReferenceView()) {
                    StudyRow(
                        icon: "speedometer",
                        iconColor: .appPrimary,
                        title: "Tốc độ & Quy tắc",
                        subtitle: "Tốc độ, khoảng cách, mức phạt"
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)

                // MARK: - Luyện tập
                SectionTitle(title: "Luyện tập")
                    .padding(.bottom, 8)

                NavigationLink(destination: QuestionView(topicKey: "all_questions", startIndex: 0)) {
                    StudyRow(
                        icon: "text.book.closed.fill",
                        iconColor: .appPrimary,
                        title: "Tất cả câu hỏi",
                        subtitle: "\(totalQuestions) câu hỏi theo thứ tự"
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)

                NavigationLink(destination: TopicsView()) {
                    StudyRow(
                        icon: "books.vertical.fill",
                        iconColor: .appPrimary,
                        title: "Học theo chủ đề",
                        subtitle: "5 chủ đề chính"
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)

                NavigationLink(destination: DiemLietTab()) {
                    StudyRow(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .appPrimary,
                        title: "Câu điểm liệt",
                        subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                        badgeText: dlMastery.correct == dlMastery.total && dlMastery.total > 0 ? "Done" : nil,
                        badgeColor: .appSuccess
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)

                // MARK: - Ôn tập
                SectionTitle(title: "Ôn tập")
                    .padding(.bottom, 8)

                NavigationLink(destination: WrongAnswersView()) {
                    StudyRow(
                        icon: "xmark.circle",
                        iconColor: .appPrimary,
                        title: "Câu trả lời sai",
                        subtitle: wrongCount > 0 ? "\(wrongCount) câu cần ôn lại" : "Chưa có câu sai"
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)

                NavigationLink(destination: BookmarksView()) {
                    StudyRow(
                        icon: "bookmark.fill",
                        iconColor: .appPrimary,
                        title: "Đã đánh dấu",
                        subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu đã lưu" : "Chưa đánh dấu câu nào"
                    )
                }
                .buttonStyle(.plain)
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
    let iconColor: Color
    let title: String
    let subtitle: String
    var badgeText: String? = nil
    var badgeColor: Color = .appPrimary

    var body: some View {
        HStack(spacing: 14) {
            IconBox(
                icon: icon,
                color: iconColor,
                size: 40,
                cornerRadius: 10,
                iconFontSize: 17
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 4)

            if let badge = badgeText {
                StatusBadge(text: badge, color: badgeColor, fontSize: 10)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextLight)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassCard()
    }
}
