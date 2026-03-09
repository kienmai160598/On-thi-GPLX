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
                        ListItemCard(
                            icon: "text.book.closed.fill",
                            title: "Tất cả câu hỏi",
                            subtitle: "\(totalQuestions) câu hỏi theo thứ tự",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: .appPrimary,
                            showCard: false
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: TopicsView()) {
                        ListItemCard(
                            icon: "books.vertical.fill",
                            title: "Học theo chủ đề",
                            subtitle: "\(questionStore.topics.count) chủ đề chính",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: .topicKyThuat,
                            showCard: false
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }

                    Divider().padding(.horizontal, 16)

                    Button { openExam(.flashcard(topicKey: AppConstants.TopicKey.allQuestions)) } label: {
                        ListItemCard(
                            icon: "rectangle.on.rectangle.angled",
                            title: "Flashcard",
                            subtitle: "Lật thẻ ôn nhanh",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: .topicSaHinh,
                            showCard: false
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: CriticalQuestionsTab()) {
                        ListItemCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "Câu điểm liệt",
                            subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: .appError,
                            showCard: false
                        ) {
                            if dlMastery.correct == dlMastery.total && dlMastery.total > 0 {
                                StatusBadge(text: "Done", color: .appSuccess, fontSize: 10)
                            }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }
                }
                .glassCard()

                // MARK: - Ôn tập
                SectionTitle(title: "Ôn tập")

                VStack(spacing: 0) {
                    NavigationLink(destination: WrongAnswersView()) {
                        ListItemCard(
                            icon: "xmark.circle.fill",
                            title: "Câu trả lời sai",
                            subtitle: wrongCount > 0 ? "\(wrongCount) câu cần ôn lại" : "Chưa có câu sai",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: wrongCount > 0 ? .appWarning : .appTextLight,
                            showCard: false
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: BookmarksView()) {
                        ListItemCard(
                            icon: "bookmark.fill",
                            title: "Đã đánh dấu",
                            subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu đã lưu" : "Chưa đánh dấu câu nào",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: bookmarkCount > 0 ? .topicCauTao : .appTextLight,
                            showCard: false
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }
                }
                .glassCard()

                // MARK: - Tra cứu
                SectionTitle(title: "Tra cứu")

                VStack(spacing: 0) {
                    NavigationLink(destination: TrafficSignsReferenceView()) {
                        ListItemCard(
                            icon: "diamond.fill",
                            title: "Biển báo giao thông",
                            subtitle: "47 biển báo phổ biến",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: .topicBienBao,
                            showCard: false
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }

                    Divider().padding(.horizontal, 16)

                    NavigationLink(destination: SpeedDistanceReferenceView()) {
                        ListItemCard(
                            icon: "speedometer",
                            title: "Tốc độ & Quy tắc",
                            subtitle: "Tốc độ, khoảng cách, mức phạt",
                            iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                            iconColor: .topicSaHinh,
                            showCard: false
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
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
