import SwiftUI

/// One fixed exam-set row on the Thi thử tab — set name plus a score pill +
/// check circle when completed, or a neutral play circle (accent icon) when not
/// yet taken.
struct ExamListRow: View {
    @Environment(ThemeStore.self) private var themeStore
    let examName: String
    let latestResult: ExamResult?
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(examName)
                    .font(.appSans(size: 14.5, weight: isCompleted ? .bold : .semibold))
                    .foregroundStyle(Color.appTextDark)

                Spacer()

                if let result = latestResult {
                    let passed = result.passed
                    let pillFill   = passed ? Color(hex: 0xD9F0DA) : Color(hex: 0xFFD7CF)
                    let pillInk    = passed ? Color(hex: 0x1F5A2A) : Color(hex: 0x8A2A1F)

                    Text("\(result.score)/\(result.totalQuestions)")
                        .font(.appSans(size: 12, weight: .bold))
                        .foregroundStyle(pillInk)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(pillFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    ZStack {
                        Circle()
                            .fill(pillFill)
                            .frame(width: 34, height: 34)
                        Image(systemName: "checkmark")
                            .font(.appSans(size: 34 * 0.44, weight: .bold))
                            .foregroundStyle(pillInk)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.neutralWash)
                            .frame(width: 34, height: 34)
                        Image(systemName: "play.fill")
                            .font(.appSans(size: 34 * 0.44, weight: .bold))
                            .foregroundStyle(themeStore.primaryColor)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
