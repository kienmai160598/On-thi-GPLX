import SwiftUI

struct ScoreRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.appMono(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
            Spacer()
            Text(value)
                .font(.appMono(size: 15, weight: .bold))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .animation(.snappy, value: value)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
