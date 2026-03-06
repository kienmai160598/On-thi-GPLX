import SwiftUI

struct EmptyState: View {
    let icon: String
    let message: String
    var iconColor: Color = Color.appTextLight

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(iconColor.opacity(0.6))
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
