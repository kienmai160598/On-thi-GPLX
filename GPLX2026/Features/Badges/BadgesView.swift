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
                // MARK: - Hero header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.appPrimary)
                    }

                    VStack(spacing: 4) {
                        Text("\(unlocked)/\(badges.count)")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Color.appTextDark)
                        Text("thành tích đã mở khoá")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextMedium)
                    }

                    Text("Hoàn thành các mục tiêu học tập để mở khoá thành tích")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .glassCard()
                .padding(.bottom, 20)
                .staggered(0)

                // MARK: - Badge grid (2 columns)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(badges.enumerated()), id: \.element.id) { i, status in
                        BadgeTile(status: status)
                            .staggered(1 + i)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.secondary, Color(.systemFill))
            }
            .padding(16)
        }
        .background(Color.scaffoldBg.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Badge Tile

private struct BadgeTile: View {
    let status: BadgeStatus

    var body: some View {
        let badge = status.badge
        let isUnlocked = status.isUnlocked

        VStack(spacing: 10) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color.opacity(0.12) : Color.appDivider.opacity(0.5))
                    .frame(width: 48, height: 48)
                Image(systemName: badge.sfSymbol)
                    .font(.system(size: 22))
                    .foregroundStyle(isUnlocked ? badge.color : Color.appTextLight)
            }

            // Title
            Text(badge.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isUnlocked ? Color.appTextDark : Color.appTextLight)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Description
            Text(badge.description)
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextMedium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Progress
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
