import SwiftUI

struct QuestionImage: View {
    let imageName: String

    var body: some View {
        if let path = Bundle.main.path(forResource: imageName, ofType: nil),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appDivider)
                .frame(height: 180)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(Color.appTextLight)
                }
        }
    }
}
