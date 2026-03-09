import SwiftUI

struct ExamCountdownCard: View {
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        if let daysLeft = progressStore.daysUntilExam {
            let today = progressStore.todayProgress

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("\(daysLeft)")
                            .font(.system(size: 36, weight: .heavy).monospacedDigit())
                            .foregroundStyle(daysLeft <= 7 ? Color.appError : Color.appPrimary)
                            .contentTransition(.numericText())
                        Text("ngày còn lại")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.appTextMedium)
                    }
                    .frame(width: 90)

                    Rectangle().fill(Color.appDivider).frame(width: 1, height: 48)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hôm nay")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                            .textCase(.uppercase)

                        HStack(spacing: 8) {
                            Text("\(today.done)/\(today.goal)")
                                .font(.system(size: 20, weight: .bold).monospacedDigit())
                                .foregroundStyle(today.done >= today.goal ? Color.appSuccess : Color.appTextDark)
                                .contentTransition(.numericText())

                            Text("câu")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.appTextMedium)

                            if today.done >= today.goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appSuccess)
                                    .font(.system(size: 16))
                            }
                        }

                        ProgressView(value: min(Double(today.done) / Double(max(today.goal, 1)), 1.0))
                            .tint(today.done >= today.goal ? Color.appSuccess : Color.appPrimary)
                    }
                }
            }
            .padding(20)
            .glassCard()
        }
    }
}
