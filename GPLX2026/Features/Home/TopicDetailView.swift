import SwiftUI

struct TopicDetailView: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)
    @Environment(\.dismiss) private var dismiss

    private var accentColor: Color {
        if item.attempted == 0 { return .appTextLight }
        return item.accuracy < 0.5 ? .appError : item.accuracy < 0.8 ? .appWarning : .appSuccess
    }

    private var statusLabel: String {
        if item.attempted == 0 { return "Chưa học" }
        if item.accuracy >= 0.8 { return "Tốt" }
        if item.accuracy >= 0.5 { return "Cần ôn" }
        return "Yếu"
    }

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Image(systemName: item.topic.sfSymbol)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(accentColor)
                }

                VStack(spacing: 8) {
                    Text(item.topic.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .multilineTextAlignment(.center)

                    Text(item.topic.topicDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    StatusBadge(text: statusLabel, color: accentColor, fontSize: 12)
                }

                VStack(spacing: 16) {
                    if item.attempted > 0 {
                        Text("\(Int(item.accuracy * 100))%")
                            .font(.system(size: 56, weight: .heavy).monospacedDigit())
                            .foregroundStyle(accentColor)
                    } else {
                        Text("—")
                            .font(.system(size: 56, weight: .heavy))
                            .foregroundStyle(Color.appTextLight)
                    }

                    VStack(spacing: 8) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appDivider)
                                .frame(height: 10)
                                .frame(maxWidth: .infinity)

                            if item.total > 0 {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(accentColor)
                                    .frame(height: 10)
                                    .frame(maxWidth: .infinity)
                                    .scaleEffect(x: Double(item.correct) / Double(item.total), y: 1, anchor: .leading)
                            }
                        }
                        .clipped()

                        Text("\(item.correct)/\(item.total) câu đúng")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.appTextMedium)
                    }
                }
                .padding(20)
                .glassCard()

                LazyVGrid(columns: gridColumns, spacing: 10) {
                    GridStatCell(icon: "checkmark.circle.fill", value: "\(item.correct)", label: "Đúng", color: .appSuccess)
                    GridStatCell(icon: "xmark.circle.fill", value: "\(max(item.attempted - item.correct, 0))", label: "Sai", color: .appError)
                    GridStatCell(icon: "questionmark.circle", value: "\(item.total - item.attempted)", label: "Chưa làm", color: .appTextLight)
                    GridStatCell(icon: "list.number", value: "\(item.total)", label: "Tổng câu hỏi", color: .appTextDark)
                }

                NavigationLink(destination: QuestionView(topicKey: item.topic.key, startIndex: 0)) {
                    AppButton(icon: "play.fill", label: "Ôn tập chủ đề này")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .screenHeader(item.topic.shortName)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CloseButton { dismiss() }
            }
        }
        .hidesTabBar()
    }
}

// MARK: - Grid Stat Cell

private struct GridStatCell: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .heavy).monospacedDigit())
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .glassCard()
    }
}
