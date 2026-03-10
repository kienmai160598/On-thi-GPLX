import SwiftUI

// MARK: - ExamBottomBar

/// Unified bottom bar for all exam/learn/flashcard screens.
/// Supports optional leading widget, main action button, and question grid.
struct ExamBottomBar: View {
    let currentIndex: Int
    let totalCount: Int
    let answeredIndices: Set<Int>
    let nextLabel: String
    var prevLabel: String = "Trước"
    var prevIcon: String? = nil
    var isNextDisabled: Bool = false
    var isPrevDisabled: Bool? = nil
    var showPrev: Bool = true
    let onPrev: () -> Void
    let onNext: () -> Void
    let onSelectIndex: (Int) -> Void
    var leadingWidget: AnyView? = nil

    var body: some View {
        HStack(spacing: 10) {
            if let leading = leadingWidget {
                leading
            }

            if showPrev {
                Button {
                    Haptics.selection()
                    onPrev()
                } label: {
                    AppButton(icon: prevIcon, label: prevLabel, style: .secondary, height: 48)
                }
                .disabled(isPrevDisabled ?? (currentIndex == 0))
            }

            Button {
                Haptics.selection()
                onNext()
            } label: {
                AppButton(label: nextLabel, height: 48)
            }
            .disabled(isNextDisabled)

            QuestionGridButton(
                current: currentIndex + 1,
                total: totalCount,
                answeredIndices: answeredIndices
            ) { index in
                onSelectIndex(index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, bottomSafeArea)
    }

    private var bottomSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 0
    }
}
