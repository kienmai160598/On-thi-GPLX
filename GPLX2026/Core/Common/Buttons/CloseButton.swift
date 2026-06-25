import SwiftUI

struct CloseButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.appSans(size: 16, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}
