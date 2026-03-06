import SwiftUI

struct BadgesView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        let badges = progressStore.badgeStatuses(diemLietQuestions: questionStore.diemLietQuestions)
        let unlocked = badges.filter(\.isUnlocked).count

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.1))
                            .frame(width: 96, height: 96)
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.appPrimary)
                    }

                    VStack(spacing: 6) {
                        Text("\(unlocked)/\(badges.count)")
                            .font(.system(size: 36, weight: .heavy).monospacedDigit())
                            .foregroundStyle(Color.appTextDark)
                            .contentTransition(.numericText())
                        Text("thành tích đã mở khoá")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.appTextMedium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .glassCard()

                // Badge grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(badges, id: \.id) { status in
                        BadgeTile(status: status)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .screenHeader("Thành tích")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CloseButton { dismiss() }
            }
        }
    }
}

// MARK: - Badge Tile

private struct BadgeTile: View {
    let status: BadgeStatus

    var body: some View {
        let badge = status.badge
        let isUnlocked = status.isUnlocked

        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color.opacity(0.12) : Color.appDivider.opacity(0.5))
                    .frame(width: 56, height: 56)
                Image(systemName: badge.sfSymbol)
                    .font(.system(size: 26))
                    .foregroundStyle(isUnlocked ? badge.color : Color.appTextLight)
            }

            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(isUnlocked ? Color.appTextDark : Color.appTextLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(badge.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMedium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Đã mở khoá")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(badge.color)
            } else {
                VStack(spacing: 4) {
                    ProgressBarView(fraction: status.fraction, color: badge.color, height: 4, cornerRadius: 2)
                    Text("\(status.progress)/\(status.target)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.appTextLight)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}
