import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let subtitle: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            heroArea
                .staggered(0)

            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextDark)
                .padding(.top, 40)
                .staggered(1)

            Text(page.subtitle)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextMedium)
                .padding(.top, 12)
                .staggered(2)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private var heroArea: some View {
        switch page.id {
        case 1:
            featureIconsHero
        default:
            singleIconHero
        }
    }

    @State private var bouncetrigger = 0

    private var singleIconHero: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 180, height: 180)

            if page.id == 2 {
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(Color.appPrimary)
                    .symbolEffect(.breathe, isActive: true)
            } else {
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(Color.appPrimary)
                    .symbolEffect(.bounce, value: bouncetrigger)
                    .onAppear { bouncetrigger += 1 }
            }
        }
    }

    private var featureIconsHero: some View {
        HStack(spacing: 20) {
            featureIcon(icon: "book.fill", label: "Lý thuyết", delay: 0)
            featureIcon(icon: "checkmark.circle.fill", label: "Thi thử", delay: 1)
            featureIcon(icon: "chart.line.uptrend.xyaxis", label: "Tiến độ", delay: 2)
        }
    }

    private func featureIcon(icon: String, label: String, delay: Int) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)

                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.appPrimary)
                    .symbolEffect(.wiggle, options: .repeating.speed(0.5), isActive: true)
            }

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
