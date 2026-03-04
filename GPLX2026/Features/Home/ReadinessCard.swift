import SwiftUI

struct ReadinessCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let score = progressStore.readinessScore(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )
        let pct = Int(score * 100)
        let dl = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let totalAttempted = progressStore.totalAttemptedCount(topics: questionStore.topics)

        let isReady = pct >= 80 && dl.correct == dl.total && totalAttempted >= 400
        let statusColor = isReady ? Color.appSuccess : pct >= 50 ? Color.appWarning : Color.appError
        let statusIcon = isReady ? "checkmark.shield.fill" : "exclamationmark.triangle.fill"
        let statusText = isReady ? "Sẵn sàng thi" : pct >= 50 ? "Cần ôn thêm" : "Chưa sẵn sàng"

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: statusIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusText)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(statusColor)
                    Text("Độ sẵn sàng: \(pct)%")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                }

                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appDivider)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(statusColor)
                        .frame(width: geo.size.width * score, height: 8)
                }
            }
            .frame(height: 8)

            HStack(spacing: 0) {
                ReadinessDetail(
                    label: "Điểm liệt",
                    value: "\(dl.correct)/\(dl.total)",
                    color: dl.correct == dl.total && dl.total > 0 ? .appSuccess : .appError
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 24)

                ReadinessDetail(
                    label: "Đã làm",
                    value: "\(totalAttempted)/600",
                    color: totalAttempted >= 400 ? .appSuccess : .appTextMedium
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 24)

                let passRate = progressStore.examHistory.isEmpty ? 0 :
                    Double(progressStore.examHistory.filter(\.passed).count) / Double(progressStore.examHistory.count)
                ReadinessDetail(
                    label: "Tỉ lệ đậu",
                    value: progressStore.examHistory.isEmpty ? "--" : "\(Int(passRate * 100))%",
                    color: passRate >= 0.8 ? .appSuccess : .appTextMedium
                )
            }
        }
        .padding(16)
        .glassCard()
    }
}

// MARK: - Readiness Detail

private struct ReadinessDetail: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
    }
}
