import SwiftUI

// MARK: - HazardHistoryView
//
// Dedicated "Lịch sử mô phỏng" screen (design node IS9s3): a three-stat summary
// (phiên / điểm TB / cao nhất), then the full list of hazard-perception sessions
// as tappable rows that push the per-session detail. The session title is
// inferred from the situations played (single chapter → "Chương N · …", else a
// generic "Phiên luyện tập"). A toolbar trash button clears history.

struct HazardHistoryView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(LayoutMetrics.self) private var metrics

    @State private var showClearConfirm = false

    var body: some View {
        let history = progressStore.hazardHistory

        ScrollView {
            if history.isEmpty {
                EmptyState(icon: "play.rectangle", message: "Chưa có phiên mô phỏng nào.")
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    summary(history)

                    SectionTitle(title: "Phiên gần đây · \(history.count)")

                    VStack(spacing: 10) {
                        ForEach(history) { result in
                            NavigationLink {
                                HazardHistoryDetailView(result: result)
                            } label: {
                                row(result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .screenHeader("Lịch sử mô phỏng", titleDisplayMode: .inline)
        .toolbar {
            if !history.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showClearConfirm = true } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.appError)
                    .accessibilityLabel("Xoá lịch sử mô phỏng")
                }
            }
        }
        .confirmationDialog("Xoá lịch sử mô phỏng?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Xoá tất cả", role: .destructive) { progressStore.clearHazardHistory() }
            Button("Huỷ", role: .cancel) {}
        } message: {
            Text("Toàn bộ kết quả mô phỏng sẽ bị xoá vĩnh viễn.")
        }
    }

    // MARK: - Pieces

    private func summary(_ history: [HazardResult]) -> some View {
        let averagePoints = Int((history.map { Double($0.totalScore) }.reduce(0, +) / Double(history.count)).rounded())
        let best = history.max { $0.scorePercentage < $1.scorePercentage }
        return HistorySummaryCard(stats: [
            .init(value: "\(history.count)", label: "Phiên"),
            .init(value: "\(averagePoints)", label: "Điểm TB"),
            .init(value: best.map { "\($0.totalScore)/\($0.maxScore)" } ?? "—", label: "Cao nhất")
        ])
    }

    private func row(_ result: HazardResult) -> some View {
        let quality = HistoryQuality.hazard(result.scorePercentage)
        return HistoryItemRow(
            icon: "play.rectangle.fill",
            iconColor: quality.color,
            title: title(for: result),
            meta: "\(HistoryDate.string(from: result.date)) · \(result.situationCount) TH",
            value: "\(result.totalScore)/\(result.maxScore)",
            valueColor: quality.color,
            status: quality.label
        )
    }

    /// "Chương N · <name>" when every situation in the session belongs to one
    /// chapter, otherwise a generic session label.
    private func title(for result: HazardResult) -> String {
        let ids = Set(result.details.map(\.situationId))
        guard !ids.isEmpty else { return "Phiên luyện tập" }
        if let chapter = HazardSituation.chapters.first(where: { chapter in
            ids.allSatisfy { chapter.range.contains($0) }
        }) {
            return "Chương \(chapter.id) · \(chapter.name)"
        }
        return "Phiên luyện tập"
    }
}
