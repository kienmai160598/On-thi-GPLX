import SwiftUI

struct QuestionGridButton: View {
    @Environment(LayoutMetrics.self) private var metrics

    let current: Int
    let total: Int
    let answeredIndices: Set<Int>
    let onSelect: (Int) -> Void

    @State private var showGrid = false

    var body: some View {
        Button {
            showGrid = true
        } label: {
            ProgressRing(current: current, total: total)
        }
        .sheet(isPresented: $showGrid) {
            ExamQuestionGridSheet(
                totalQuestions: total,
                answeredIndices: answeredIndices,
                currentIndex: current - 1
            ) { index in
                onSelect(index)
                showGrid = false
            }
            .presentationDetents(metrics.isWide ? [.large] : [.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Material.ultraThinMaterial)
        }
    }
}
