import SwiftUI

struct QuestionImage: View {
    let url: String

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            case .failure:
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appDivider)
                    .frame(height: 180)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(Color.appTextLight)
                    }
            default:
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appDivider.opacity(0.5))
                    .frame(height: 180)
                    .overlay {
                        ProgressView()
                            .tint(Color.appPrimary)
                    }
            }
        }
    }
}
