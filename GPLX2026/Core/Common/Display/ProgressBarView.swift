import SwiftUI

struct ProgressBarView: View {
    let fraction: Double
    var color: Color = .appPrimary
    var trackColor: Color = .appDivider
    var height: CGFloat = 6
    var cornerRadius: CGFloat = 3

    private var clampedFraction: Double {
        min(max(fraction, 0), 1)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(trackColor)
            .frame(height: height)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .frame(width: nil, height: height)
                    .scaleEffect(x: clampedFraction, anchor: .leading)
            }
            .clipped()
    }
}
