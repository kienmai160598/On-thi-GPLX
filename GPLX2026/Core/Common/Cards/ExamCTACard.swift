import SwiftUI

struct ExamCTACard: View {
    let buttonLabel: String
    let rules: [(icon: String, text: String)]
    let tip: String
    let action: () -> Void
    var onButtonHidden: ((Bool) -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Button(action: action) {
                AppButton(icon: "play.fill", label: buttonLabel)
            }
            .buttonStyle(.plain)
            .onGeometryChange(for: Bool.self) { proxy in
                proxy.frame(in: .scrollView(axis: .vertical)).minY < 0
            } action: { hidden in
                onButtonHidden?(hidden)
            }

            HStack(spacing: 16) {
                ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                    RulePill(icon: rule.icon, text: rule.text)
                }
            }

            Text(tip)
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(3)
        }
        .padding(20)
        .glassCard()
    }
}
