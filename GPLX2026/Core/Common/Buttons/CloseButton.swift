import SwiftUI

struct CloseButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
