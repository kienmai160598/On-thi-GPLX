import SwiftUI

struct AppIconButton: View {
    let icon: String
    var size: CGFloat = 44
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"

    var body: some View {
        if #available(iOS 26.0, *) {
            iconContent
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            iconContent
                .background(Color.cardBg)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.appDivider, lineWidth: 0.5))
        }
    }

    private var iconContent: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
            .frame(width: size, height: size)
    }
}
