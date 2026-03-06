import SwiftUI

struct RulePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appPrimary)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.appPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
