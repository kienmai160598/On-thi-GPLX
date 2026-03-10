import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let subtitle: String
}

struct OnboardingPageView: View {
    @Environment(ThemeStore.self) private var themeStore
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            heroArea

            Text(page.title)
                .font(.system(size: 32, weight: .heavy))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextDark)
                .padding(.top, 44)

            Text(page.subtitle)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(4)
                .padding(.top, 14)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private var heroArea: some View {
        switch page.id {
        case 2:
            examStructureHero
        case 3:
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
                .frame(width: 200, height: 200)

            if page.id == 5 {
                Image(systemName: page.icon)
                    .font(.system(size: 88))
                    .foregroundStyle(themeStore.primaryColor)
                    .symbolEffect(.breathe, isActive: true)
            } else {
                Image(systemName: page.icon)
                    .font(.system(size: 88))
                    .foregroundStyle(themeStore.primaryColor)
                    .symbolEffect(.bounce, value: bouncetrigger)
                    .onAppear { bouncetrigger += 1 }
            }
        }
    }

    private var examStructureHero: some View {
        VStack(spacing: 12) {
            examPartRow(icon: "doc.text.fill", part: "Phần 1", name: "Lý thuyết", detail: "\(LicenseType.current.questionsPerExam) câu · \(LicenseType.current.totalTimeSeconds / 60) phút · ≥\(LicenseType.current.passThreshold) đạt", color: .topicQuyDinh)
            examPartRow(icon: "photo.fill", part: "Phần 2", name: "Sa hình", detail: "20 hình · 60s mỗi câu · ≥70%", color: .topicSaHinh)
            examPartRow(icon: "play.circle.fill", part: "Phần 3", name: "Tình huống", detail: "10 video · ≥35/50 điểm", color: .topicBienBao)

            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appError)
                Text("Sai câu điểm liệt = Trượt ngay")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appError)
            }
            .padding(.top, 4)
        }
    }

    private func examPartRow(icon: String, part: String, name: String, detail: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(part)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appTextMedium)
                    Text(name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                }
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextLight)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var featureIconsHero: some View {
        HStack(spacing: 24) {
            featureIcon(icon: "book.fill", label: "Lý thuyết", delay: 0)
            featureIcon(icon: "checkmark.circle.fill", label: "Thi thử", delay: 1)
            featureIcon(icon: "chart.line.uptrend.xyaxis", label: "Tiến độ", delay: 2)
        }
    }

    private func featureIcon(icon: String, label: String, delay: Int) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(themeStore.primaryColor)
                    .symbolEffect(.wiggle, options: .repeating.speed(0.5), isActive: true)
            }

            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
