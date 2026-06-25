import SwiftUI

/// One-line subtitle shown at the top of a tab's scroll content, beneath the
/// native large navigation title. Shared by the Home tabs so the subtitle font
/// and spacing stay in sync.
struct TabPageSubtitle: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.appSans(size: 13.5))
            .foregroundStyle(Color.appTextMedium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
}
