import SwiftUI

// MARK: - ExamTimerCapsule

struct ExamTimerCapsule: View {
    let text: String
    let isUrgent: Bool

    var body: some View {
        let content = HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.appMono(size: 14))
                .foregroundStyle(isUrgent ? Color.appError : Color.appTextMedium)
            Text(text)
                .font(.appMono(size: 16, weight: .bold))
                .foregroundStyle(isUrgent ? Color.appError : Color.appTextDark)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)

        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .background(isUrgent ? Color.appError.opacity(0.1) : Color.appDivider.opacity(0.3))
                .clipShape(Capsule())
        }
    }
}
