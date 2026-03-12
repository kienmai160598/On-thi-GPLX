import SwiftUI

struct ExamCountdownCard: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore

    var body: some View {
        if progressStore.daysUntilExam == nil {
            NavigationLink(destination: SettingsView()) {
                HStack(spacing: 14) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.appMono(size: 22))
                        .foregroundStyle(themeStore.primaryColor)
                        .frame(width: 44, height: 44)
                        .background(themeStore.primaryColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Đặt ngày thi")
                            .font(.appMono(size: 16, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                        Text("Theo dõi tiến độ ôn tập")
                            .font(.appMono(size: 13))
                            .foregroundStyle(Color.appTextMedium)
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.appMono(size: 12, weight: .medium))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(12)
                .glassCard()
            }
            .buttonStyle(.plain)
        } else if let daysLeft = progressStore.daysUntilExam {
            let today = progressStore.todayProgress

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("\(daysLeft)")
                            .font(.appMono(size: 36, weight: .bold))
                            .foregroundStyle(daysLeft <= 7 ? Color.appWarning : themeStore.primaryColor)
                            .contentTransition(.numericText())
                        Text("ngày còn lại")
                            .font(.appMono(size: 12, weight: .medium))
                            .foregroundStyle(Color.appTextMedium)
                    }
                    .frame(width: 90)

                    Rectangle().fill(Color.appDivider).frame(width: 1, height: 48)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hôm nay")
                            .font(.appMono(size: 12, weight: .medium))
                            .foregroundStyle(Color.appTextLight)
                            .textCase(.uppercase)

                        HStack(spacing: 8) {
                            Text("\(today.done)/\(today.goal)")
                                .font(.appMono(size: 20, weight: .bold))
                                .foregroundStyle(today.done >= today.goal ? Color.appSuccess : Color.appTextDark)
                                .contentTransition(.numericText())

                            Text("câu")
                                .font(.appMono(size: 14))
                                .foregroundStyle(Color.appTextMedium)

                            if today.done >= today.goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appSuccess)
                                    .font(.appMono(size: 16))
                            }
                        }

                        ProgressView(value: min(Double(today.done) / Double(max(today.goal, 1)), 1.0))
                            .tint(today.done >= today.goal ? Color.appSuccess : themeStore.primaryColor)
                    }
                }
            }
            .padding(12)
            .glassCard()
        }
    }
}
