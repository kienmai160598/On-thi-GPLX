import SwiftUI

/// Light hero card variant (semi-transparent white card, amber border, dark
/// serif title with a gold circular play button). Used as the headline CTA on
/// both the Practice ("Luyện tập") and Mô phỏng tabs so they share one look.
struct LightFeatureCard: View {
    let eyebrow: String
    let title: String
    let tags: [String]
    let icon: String
    let action: () -> Void

    private let amberBorder = Color(hex: 0xFFE9B0)
    private let eyebrowColor = Color(hex: 0x7A4A00)
    private let goldFill = Color(hex: 0xFFC233)
    private let goldInk  = Color(hex: 0x7A4A00)

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Text(eyebrow.uppercased())
                    .font(.appSans(size: 10, weight: .heavy))
                    .tracking(1.2)
                    .foregroundStyle(eyebrowColor)

                Text(title)
                    .font(.appSerif(size: 20, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .fixedSize(horizontal: false, vertical: true)

                if !tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(tags.enumerated()), id: \.offset) { _, tag in
                            Text(tag)
                                .font(.appSans(size: 11, weight: .semibold))
                                .foregroundStyle(Color(hex: 0x7A7166))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Color(hex: 0x0F0F12).opacity(0.07),
                                    in: Capsule()
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: action) {
                Image(systemName: icon)
                    .font(.appSans(size: 20, weight: .bold))
                    .foregroundStyle(goldInk)
                    .frame(width: 52, height: 52)
                    .background(goldFill, in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(amberBorder, lineWidth: 1)
        )
    }
}
