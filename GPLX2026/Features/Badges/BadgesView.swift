import SwiftUI

struct BadgesView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        let badges = progressStore.badgeStatuses
        let unlocked = badges.filter(\.isUnlocked).count

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                DetailHero(
                    icon: "trophy.fill",
                    iconColor: .appPrimary,
                    title: "\(unlocked)/\(badges.count)",
                    subtitle: "thành tích đã mở khoá",
                    description: "Hoàn thành các mục tiêu học tập để mở khoá thành tích"
                )
                .padding(.bottom, 20)

                // MARK: - Badge grid (2 columns)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(badges, id: \.id) { status in
                        BadgeTile(status: status)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 20)
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

        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color.opacity(0.12) : Color.appDivider.opacity(0.5))
                    .frame(width: 52, height: 52)
                Image(systemName: badge.sfSymbol)
                    .font(.system(size: 24))
                    .foregroundStyle(isUnlocked ? badge.color : Color.appTextLight)
            }

            Text(badge.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isUnlocked ? Color.appTextDark : Color.appTextLight)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(badge.description)
                .font(.system(size: 12))
                .foregroundStyle(Color.appTextMedium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Đã mở khoá")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(badge.color)
            } else {
                VStack(spacing: 4) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.appDivider)
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(badge.color)
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                            .scaleEffect(x: status.fraction, y: 1, anchor: .leading)
                    }
                    .clipped()

                    Text("\(status.progress)/\(status.target)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.appTextLight)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}
