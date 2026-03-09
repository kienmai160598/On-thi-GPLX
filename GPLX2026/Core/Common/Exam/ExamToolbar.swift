import SwiftUI

// MARK: - ExamToolbar

struct ExamToolbar: ViewModifier {
    let timerText: String
    let isUrgent: Bool
    let isBookmarked: Bool
    @Binding var showExitDialog: Bool
    let onToggleBookmark: () -> Void
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Color.scaffoldBg.ignoresSafeArea()
                    AnimatedBackground()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showExitDialog = true
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .principal) {
                    ExamTimerCapsule(text: timerText, isUrgent: isUrgent)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Haptics.impact(.light)
                        onToggleBookmark()
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                }
            }
            .alert("Thoát bài thi?", isPresented: $showExitDialog) {
                Button("Tiếp tục", role: .cancel) {}
                Button("Thoát", role: .destructive) { onDismiss() }
            } message: {
                Text("Bài thi sẽ không được lưu.")
            }
    }
}

extension View {
    func examToolbar(
        timerText: String,
        isUrgent: Bool,
        isBookmarked: Bool,
        showExitDialog: Binding<Bool>,
        onToggleBookmark: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(ExamToolbar(
            timerText: timerText,
            isUrgent: isUrgent,
            isBookmarked: isBookmarked,
            showExitDialog: showExitDialog,
            onToggleBookmark: onToggleBookmark,
            onDismiss: onDismiss
        ))
    }
}
