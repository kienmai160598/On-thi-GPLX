import SwiftUI

struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color.appTextMedium)
            .tracking(0.3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
