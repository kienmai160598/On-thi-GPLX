import SwiftUI

struct QuestionImage: View {
    let imageName: String
    var altText: String? = nil

    var body: some View {
        if let path = Bundle.main.path(forResource: imageName, ofType: nil),
           let uiImage = UIImage(contentsOfFile: path) {
            let hasAlt = !(altText ?? "").isEmpty
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel(hasAlt ? Text(altText!) : Text(""))
                .accessibilityHidden(!hasAlt)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appDivider)
                .frame(height: 180)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(Color.appTextLight)
                        .accessibilityHidden(true)
                }
                .accessibilityHidden(true)
        }
    }
}
