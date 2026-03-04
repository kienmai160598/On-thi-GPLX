import SwiftUI

// MARK: - HomeTab

struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @Namespace private var heroNS

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Readiness card
                ReadinessCard()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                // MARK: - Stats row
                StatsRow()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: - Badges preview
                badgesCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: - Topic analysis
                SectionTitle(title: "Phân tích chủ đề")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                topicList
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .navigationDestination(for: HeroDestination.self) { dest in
            switch dest {
            case .badges:
                BadgesView()
                    .navigationTransition(.zoom(sourceID: dest, in: heroNS))
            case .topic(let key):
                let topicStats = progressStore.weakTopics(topics: questionStore.topics)
                    .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }
                if let item = topicStats.first(where: { $0.topic.key == key }) {
                    TopicDetailView(item: item)
                        .navigationTransition(.zoom(sourceID: dest, in: heroNS))
                }
            }
        }
        .screenHeader("Trang chủ")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }

    // MARK: - Badges card

    @ViewBuilder
    private var badgesCard: some View {
        let badges = progressStore.badgeStatuses
        let unlocked = badges.filter(\.isUnlocked).count
        let nextBadge = badges.first(where: { !$0.isUnlocked })

        NavigationLink(value: HeroDestination.badges) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.12))
                        .frame(width: 64, height: 64)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.appPrimary)
                }

                VStack(spacing: 4) {
                    Text("Thành tích")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)

                    Text("\(unlocked)/\(badges.count) đã mở khoá")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                }

                if let next = nextBadge {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: next.badge.sfSymbol)
                                .font(.system(size: 13))
                                .foregroundStyle(next.badge.color)
                            Text("Tiếp: \(next.badge.title)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.appTextMedium)
                        }

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.appDivider)
                                .frame(height: 6)
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(next.badge.color)
                                    .frame(width: geo.size.width * next.fraction, height: 6)
                            }
                            .frame(height: 6)
                        }

                        Text("\(next.progress)/\(next.target)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.appTextLight)
                    }
                    .padding(.horizontal, 8)
                } else {
                    Text("Đã mở khoá tất cả!")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appSuccess)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .glassCard()
        }
        .buttonStyle(.plain)
        .matchedTransitionSource(id: HeroDestination.badges, in: heroNS)
    }

    // MARK: - Topic list

    private let topicColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    @ViewBuilder
    private var topicList: some View {
        let topicStats = progressStore.weakTopics(topics: questionStore.topics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }

        LazyVGrid(columns: topicColumns, spacing: 10) {
            ForEach(topicStats, id: \.topic.id) { item in
                NavigationLink(value: HeroDestination.topic(item.topic.key)) {
                    TopicCard(item: item)
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: HeroDestination.topic(item.topic.key), in: heroNS)
            }
        }
    }
}

// MARK: - Topic Card

private struct TopicCard: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

    var body: some View {
        let accentColor = if item.attempted == 0 {
            Color.appTextLight
        } else if item.accuracy < 0.5 {
            Color.appError
        } else if item.accuracy < 0.8 {
            Color.appWarning
        } else {
            Color.appSuccess
        }

        VStack(spacing: 12) {
            IconBox(
                icon: item.topic.sfSymbol,
                color: accentColor,
                size: 44,
                cornerRadius: 11,
                iconFontSize: 19
            )

            Text(item.topic.shortName)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.appTextDark)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)

            Text(item.attempted > 0 ? "\(Int(item.accuracy * 100))%" : "—")
                .font(.system(size: 22, weight: .heavy).monospacedDigit())
                .foregroundStyle(accentColor)

            VStack(spacing: 4) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.appDivider)
                        .frame(height: 5)
                        .frame(maxWidth: .infinity)

                    if item.total > 0 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor)
                            .frame(height: 5)
                            .frame(maxWidth: .infinity)
                            .scaleEffect(x: Double(item.correct) / Double(item.total), y: 1, anchor: .leading)
                    }
                }
                .clipped()

                Text("\(item.correct)/\(item.total)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

// MARK: - Stats Row

private struct StatsRow: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let progress = progressStore.overallProgress(topics: questionStore.topics)
        let correctCount = progressStore.totalCorrectCount(topics: questionStore.topics)
        let totalQuestions = questionStore.topics.reduce(0) { $0 + $1.questionCount }
        let streak = progressStore.streakCount

        HStack(spacing: 10) {
            MiniStatCard(
                icon: "chart.pie.fill",
                iconColor: .appPrimary,
                value: "\(Int(progress * 100))%",
                label: "Tiến độ"
            )

            MiniStatCard(
                icon: "checkmark.circle.fill",
                iconColor: .appSuccess,
                value: "\(correctCount)/\(totalQuestions)",
                label: "Đã đúng"
            )

            MiniStatCard(
                icon: "flame.fill",
                iconColor: Color(hex: 0xFF6B35),
                value: "\(streak)",
                label: "Chuỗi ngày"
            )
        }
    }
}

private struct MiniStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)

            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard()
    }
}
