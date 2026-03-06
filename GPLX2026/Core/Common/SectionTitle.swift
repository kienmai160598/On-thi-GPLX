import SwiftUI

struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.appTextMedium)
            .textCase(.uppercase)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
