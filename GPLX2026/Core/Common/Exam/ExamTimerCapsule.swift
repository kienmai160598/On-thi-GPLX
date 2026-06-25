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

        content
            .background(isUrgent ? Color.appError.opacity(0.1) : Color.cardBg)
            .clipShape(Capsule())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isUrgent ? "Thời gian còn lại \(text), cảnh báo" : "Thời gian còn lại \(text)")
    }
}
