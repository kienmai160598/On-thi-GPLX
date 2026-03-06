import SwiftUI

struct MemoryTipsView: View {
    @Environment(QuestionStore.self) private var questionStore

    let topicKey: String

    var body: some View {
        let topic = questionStore.topic(forKey: topicKey) ?? Topic.all.first!
        let tips = questionStore.memoryTips(forTopicKey: topicKey)

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Topic header card
                HStack(spacing: 12) {
                    IconBox(icon: topic.sfSymbol, color: .appPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(topic.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                        Text("\(tips.count) mẹo ghi nhớ")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextMedium)
                    }

                    Spacer()
                }
                .padding(16)
                .glassCard()
                .padding(.bottom, 20)

                if tips.isEmpty {
                    VStack(spacing: 12) {
                        Spacer().frame(height: 60)
                        Text("Chưa có mẹo cho chủ đề này")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.appTextMedium)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // MARK: - Tips list
                    ForEach(Array(tips.enumerated()), id: \.offset) { _, tip in
                        TipCard(tip: tip)
                            .padding(.bottom, 10)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
        .screenHeader("Mẹo ghi nhớ")
    }
}

// MARK: - Tip Card

private struct TipCard: View {
    let tip: MemoryTip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tip.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.appTextDark)

            Text(tip.content)
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(4)
        }
        .padding(16)
        .glassCard()
    }
}
