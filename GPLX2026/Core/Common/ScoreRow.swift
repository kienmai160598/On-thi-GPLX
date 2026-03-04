import SwiftUI

struct ScoreRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
