import SwiftUI

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.appTextDark)
        }
    }
}
