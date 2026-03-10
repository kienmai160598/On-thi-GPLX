import SwiftUI

// MARK: - Achievements Card

struct AchievementsCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore

    var body: some View {
        let unlocked = progressStore.unlockedAchievements(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )
        let all = ProgressStore.Achievement.allCases

        if !unlocked.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Thành tích")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)

                    Spacer()

                    Text("\(unlocked.count)/\(all.count)")
                        .font(.system(size: 14, weight: .bold).monospacedDigit())
                        .foregroundStyle(themeStore.primaryColor)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(all, id: \.rawValue) { achievement in
                            let isUnlocked = unlocked.contains(achievement)
                            AchievementBadge(achievement: achievement, isUnlocked: isUnlocked)
                        }
                    }
                }
            }
            .padding(16)
            .glassCard()
        }
    }
}

// MARK: - Achievement Badge

private struct AchievementBadge: View {
    @Environment(ThemeStore.self) private var themeStore
    let achievement: ProgressStore.Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? themeStore.primaryColor.opacity(0.15) : Color.appDivider.opacity(0.3))
                    .frame(width: 52, height: 52)

                Image(systemName: achievement.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isUnlocked ? themeStore.primaryColor : Color.appTextLight.opacity(0.5))
            }

            Text(achievement.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(isUnlocked ? Color.appTextDark : Color.appTextLight)
                .lineLimit(1)
        }
        .frame(width: 64)
        .opacity(isUnlocked ? 1 : 0.5)
    }
}
