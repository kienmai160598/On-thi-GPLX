import SwiftUI

struct EmptyState: View {
    let icon: String
    let message: String
    var iconColor: Color = Color.appTextLight

    var body: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 100)
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(iconColor)
            Text(message)
                .font(.system(size: 16))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
    }
}
