import SwiftUI

struct MemoryTipsView: View {
    @Environment(QuestionStore.self) private var questionStore

    let topicKey: String

    var body: some View {
        let topic = questionStore.topic(forKey: topicKey) ?? Topic.all[0]
        let tips = questionStore.memoryTips(forTopicKey: topicKey)

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Topic header
                HStack(spacing: 14) {
                    IconBox(icon: topic.sfSymbol, color: .appPrimary, size: 44, cornerRadius: 8, iconFontSize: 18)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(topic.name)
                            .font(.appSerif(size: 16, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                        Text("\(tips.count) mẹo ghi nhớ")
                            .font(.appSans(size: 13))
                            .foregroundStyle(Color.appTextMedium)
                    }

                    Spacer()
                }
                .padding(12)
                .glassCard()
                .padding(.bottom, 20)

                if tips.isEmpty {
                    EmptyState(icon: "lightbulb", message: "Chưa có mẹo cho chủ đề này")
                } else {
                    ForEach(Array(tips.enumerated()), id: \.offset) { _, tip in
                        TipCard(tip: tip)
                            .padding(.bottom, 10)
                    }
                }
            }
            .padding(.horizontal, 20)
            .iPadReadable()
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .screenHeader("Mẹo ghi nhớ")
    }
}

// MARK: - Tip Card

private struct TipCard: View {
    let tip: MemoryTip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.appSans(size: 14))
                    .foregroundStyle(Color.appWarning)
                Text(tip.title)
                    .font(.appSans(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
            }

            Text(tip.content
                .replacingOccurrences(of: "<br/>", with: "\n")
                .replacingOccurrences(of: "<br>", with: "\n")
                .replacingOccurrences(of: "<br />", with: "\n")
                .replacingOccurrences(of: "; ", with: ";\n")
            )
                .font(.appSans(size: 14))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(4)
        }
        .padding(12)
        .glassCard()
    }
}
