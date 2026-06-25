import SwiftUI

// MARK: - HomeTab
//
// Rebuilt to match the Pencil design (node Voun1 · "GPLX · Trang chủ"):
// an in-content header (greeting + settings + meta chips), a single consolidated
// "Study Progress" card (mastery summary + four navigation links) and a "Lối tắt"
// six-tile shortcut grid. The greeting and settings live in the scroll content —
// not the navigation bar — so the screen starts right under the status bar; the
// navigation bar is hidden and the app background is supplied directly.

struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openExam) private var openExam

    @State private var greetingText: String = HomeTab.computeGreeting()
    @State private var dateString: String = HomeTab.computeDateString()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "EEEE · dd / MM"
        return f
    }()

    private static func computeGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Chào buổi sáng!"
        case 12..<18: return "Chào buổi chiều!"
        default: return "Chào buổi tối!"
        }
    }

    private static func computeDateString() -> String {
        let raw = dayFormatter.string(from: Date())
        return raw.prefix(1).uppercased() + raw.dropFirst()
    }

    var body: some View {
        let goalDone = progressStore.todayProgress.done >= progressStore.todayProgress.goal

        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                HomeSubheader(
                    subtitle: "Sẵn sàng ôn tập hôm nay chưa?",
                    dateString: dateString,
                    streakDays: progressStore.streakCount
                )

                HomeStudyProgressCard()

                HomeQuickActionsSection()
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .dailyGoalCelebration(isDone: goalDone)
        // Native Apple navigation: the greeting is the large title (collapses to
        // inline on scroll) and the search / settings actions live in the toolbar.
        .screenHeader(greetingText, titleDisplayMode: .large)
        .tracksTabBarCollapse()
        .toolbar {
            // Plain native toolbar buttons — the system supplies the tap target
            // and (on iOS 26) the Liquid Glass background; the accent tint comes
            // from the enclosing NavigationStack. No custom frame/padding.
            ToolbarItem(placement: .topBarTrailing) {
                Button { openExam(.search) } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Tìm kiếm")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { openExam(.settings) } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Cài đặt")
            }
        }
        .onAppear {
            greetingText = HomeTab.computeGreeting()
            dateString = HomeTab.computeDateString()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                greetingText = HomeTab.computeGreeting()
                dateString = HomeTab.computeDateString()
            }
        }
    }
}

// MARK: - Header

private struct HomeSubheader: View {
    let subtitle: String
    let dateString: String
    let streakDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Subtitle
            Text(subtitle)
                .font(.appSans(size: 13.5, weight: .regular))
                .foregroundStyle(Color.appTextMedium)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Meta chips
            HStack(spacing: 8) {
                // Day chip
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.appSans(size: 12))
                        .foregroundStyle(Color.appTextMedium)
                    Text(dateString)
                        .font(.appSans(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.cardBg, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.cardBorder, lineWidth: 1))

                // Streak chip (only when streak > 0)
                if streakDays > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.appSans(size: 12))
                            .foregroundStyle(Color.amberInk)
                        Text("\(streakDays) ngày liên tục")
                            .font(.appSans(size: 12, weight: .bold))
                            .foregroundStyle(Color.amberInk)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.amberWash, in: Capsule())
                }
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Study Progress card

private struct HomeStudyProgressCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        // Scope the headline mastery to the active license so B1 users see their
        // own bank (for B2, questionsForCurrentLicense == allQuestions, no change).
        let licenseQuestions = questionStore.questionsForCurrentLicense
        let totalCount = licenseQuestions.count
        let masteredCount = progressStore.correctCount(in: licenseQuestions)
        let fraction = totalCount > 0 ? Double(masteredCount) / Double(totalCount) : 0
        let percentInt = Int((fraction * 100).rounded())
        let remaining = max(0, totalCount - masteredCount)

        // Điểm liệt stays global to match its dedicated practice screen.
        let diemLiet = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let wrongCount = progressStore.wrongAnswers.count
        let bookmarkCount = progressStore.bookmarks.count
        let lastResult = progressStore.examHistory.first

        VStack(spacing: 16) {
            // Mastery summary
            VStack(spacing: 8) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(percentInt)%")
                        .font(.appSans(size: 34, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                        .contentTransition(.numericText())
                    Text("đã thuộc")
                        .font(.appSans(size: 14, weight: .bold))
                        .foregroundStyle(Color.appTextMedium)
                    Spacer(minLength: 0)
                }

                HStack {
                    Text("Lý thuyết · \(masteredCount) / \(totalCount) câu")
                        .font(.appSans(size: 11.5, weight: .semibold))
                        .foregroundStyle(Color.appTextMedium)
                    Spacer(minLength: 8)
                    Text("Còn \(remaining) câu")
                        .font(.appSans(size: 11.5, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                }
            }

            // Navigation links
            VStack(spacing: 0) {
                // Kết quả thi thử → last result detail, or start a mock exam.
                if let result = lastResult {
                    NavigationLink(destination: ExamHistoryDetailView(result: result)) {
                        HomeLinkRow(
                            label: "Kết quả thi thử",
                            value: "\(result.passed ? "Đạt" : "Chưa đạt") · \(result.score)/\(result.totalQuestions)",
                            valueColor: result.passed ? Color.appSuccess : Color.appError
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        openExam(.mockExam())
                    } label: {
                        HomeLinkRow(label: "Kết quả thi thử", value: "Chưa thi", valueColor: Color.appTextMedium)
                    }
                    .buttonStyle(.plain)
                }

                HomeLinkDivider()

                // Điểm liệt → dedicated practice (red is the điểm-liệt brand color).
                Button {
                    openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
                } label: {
                    HomeLinkRow(
                        label: "Điểm liệt",
                        value: "\(diemLiet.correct)/\(diemLiet.total)",
                        valueColor: Color.appError
                    )
                }
                .buttonStyle(.plain)

                HomeLinkDivider()

                // Câu sai cần ôn → wrong-answers review.
                NavigationLink(destination: WrongAnswersView()) {
                    HomeLinkRow(label: "Câu sai cần ôn", value: "\(wrongCount)", valueColor: Color.appTextDark)
                }
                .buttonStyle(.plain)

                HomeLinkDivider()

                // Đánh dấu → bookmarks. Last row: no bottom padding.
                NavigationLink(destination: BookmarksView()) {
                    HomeLinkRow(label: "Đánh dấu", value: "\(bookmarkCount)", valueColor: Color.appTextDark, isLast: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color.cardBorder, lineWidth: 1))
    }
}

private struct HomeLinkRow: View {
    let label: String
    let value: String
    let valueColor: Color
    /// The last row drops its bottom padding so the gap below it equals the
    /// card's padding (concentric: outer radius − padding = inner spacing).
    var isLast: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.appSans(size: 13.5, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.appSans(size: 14, weight: .bold))
                .foregroundStyle(valueColor)
                .contentTransition(.numericText())
            Image(systemName: "chevron.right")
                .font(.appSans(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextLight)
        }
        .padding(.top, 12)
        .padding(.bottom, isLast ? 0 : 12)
        .contentShape(Rectangle())
    }
}

private struct HomeLinkDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.appDivider.opacity(0.6))
            .frame(height: 1)
    }
}

// MARK: - Quick Actions ("Lối tắt")

private struct HomeQuickActionsSection: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.openExam) private var openExam

    private var accent: Color { themeStore.primaryColor }

    private var lastTopicName: String {
        guard let key = progressStore.lastTopicKey, !key.isEmpty else {
            return "Bắt đầu học"
        }
        switch key {
        case AppConstants.TopicKey.diemLiet: return "Câu điểm liệt"
        case AppConstants.TopicKey.allQuestions, AppConstants.TopicKey.currentLicense: return "Tất cả câu hỏi"
        case AppConstants.TopicKey.bookmarks: return "Đánh dấu"
        case AppConstants.TopicKey.wrongAnswers: return "Câu sai"
        default: return questionStore.topic(forKey: key)?.name ?? key
        }
    }

    var body: some View {
        let bookmarkCount = progressStore.bookmarks.count
        let poolCount = questionStore.questionsForCurrentLicense.count

        VStack(alignment: .leading, spacing: 12) {
            Text("Lối tắt")
                .font(.appSans(size: 18, weight: .bold))
                .tracking(-0.2)
                .foregroundStyle(Color.appTextDark)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                spacing: 8
            ) {
                // Ngẫu nhiên — draw the random start from the license-scoped pool so
                // the count shown matches the session that launches.
                HomeShortcutTile(icon: "shuffle", accent: accent, title: "Ngẫu nhiên", subtitle: "\(poolCount) câu") {
                    let randomStart = poolCount == 0 ? 0 : Int.random(in: 0..<poolCount)
                    openExam(.questionView(topicKey: AppConstants.TopicKey.currentLicense, startIndex: randomStart))
                }

                // Tốc độ & Quy tắc
                HomeShortcutLink(icon: "speedometer", accent: accent, title: "Tốc độ & Quy tắc", subtitle: "Học lý thuyết") {
                    SpeedDistanceReferenceView()
                }

                // Mô phỏng
                HomeShortcutTile(icon: "film.stack.fill", accent: accent, title: "Mô phỏng", subtitle: "120 tình huống") {
                    openExam(.hazardTest(mode: .practice))
                }

                // Tiếp tục
                HomeShortcutTile(icon: "play.fill", accent: accent, title: "Tiếp tục", subtitle: lastTopicName) {
                    openExam(.questionView(
                        topicKey: progressStore.lastTopicKey ?? AppConstants.TopicKey.currentLicense,
                        startIndex: progressStore.lastQuestionIndex
                    ))
                }

                // Đã lưu
                HomeShortcutLink(icon: "bookmark.fill", accent: accent, title: "Đã lưu", subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu" : "Xem lại") {
                    BookmarksView()
                }

                // Biển báo
                HomeShortcutLink(icon: "signpost.right.fill", accent: accent, title: "Biển báo", subtitle: "Giao thông") {
                    TrafficSignsReferenceView()
                }
            }
        }
    }
}

/// Shared visual for a shortcut tile — accent icon box + title + subtitle in a
/// white rounded card. Used by both the action (`Button`) and navigation
/// (`NavigationLink`) variants so every tile looks identical.
private struct HomeShortcutTileContent: View {
    let icon: String
    let accent: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 8) {
            IconBox(icon: icon, color: accent, size: 34, cornerRadius: 8, iconFontSize: 17, iconWeight: .medium, background: .neutralWash)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.appSans(size: 12.5, weight: .bold))
                    .tracking(-0.2)
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(subtitle)
                    .font(.appSans(size: 11, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color.cardBorder, lineWidth: 1))
    }
}

private struct HomeShortcutTile: View {
    let icon: String
    let accent: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HomeShortcutTileContent(icon: icon, accent: accent, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }
}

/// Navigation variant of `HomeShortcutTile` — same visual, but pushes a
/// destination instead of running a closure.
private struct HomeShortcutLink<Destination: View>: View {
    let icon: String
    let accent: Color
    let title: String
    let subtitle: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HomeShortcutTileContent(icon: icon, accent: accent, title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }
}
