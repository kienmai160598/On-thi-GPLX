import SwiftUI

/// Pushed detail screen holding the granular data-reset rows plus "Xoá tất cả",
/// extracted from Settings to keep that screen lean.
struct DataManagementView: View {
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage(AppConstants.StorageKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    @State private var showResetAllAlert = false
    @State private var resetConfirmation: ResetAction?
    @State private var toast: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(spacing: 0) {
                    resetRow(icon: "book.closed",        title: "Tiến độ học",        subtitle: "Xoá tiến độ tất cả chủ đề",  action: .topicProgress)
                    divider()
                    resetRow(icon: "doc.text",           title: "Lịch sử thi thử",    subtitle: "Xoá kết quả thi thử",        action: .examHistory)
                    divider()
                    resetRow(icon: "photo.on.rectangle", title: "Lịch sử mô phỏng",  subtitle: "Xoá kết quả mô phỏng",      action: .simulationHistory)
                    divider()
                    resetRow(icon: "play.rectangle",     title: "Lịch sử tình huống", subtitle: "Xoá kết quả tình huống",    action: .hazardHistory)
                    divider()
                    resetRow(icon: "bookmark",           title: "Đánh dấu",           subtitle: "Xoá tất cả đánh dấu",       action: .bookmarks)
                    divider()
                    resetRow(icon: "xmark.circle",       title: "Câu sai",            subtitle: "Xoá danh sách câu sai",     action: .wrongAnswers)
                }
                .glassCard(cornerRadius: 20)

                Button { showResetAllAlert = true } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "trash")
                            .font(.appSans(size: 16))
                            .foregroundStyle(Color.appError)
                            .frame(width: 22)
                        Text("Xoá tất cả dữ liệu")
                            .font(.appSans(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appError)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassCard(cornerRadius: 20)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Xoá tất cả dữ liệu")
                .accessibilityHint("Xoá toàn bộ tiến độ học, lịch sử thi và đánh dấu")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .screenHeader("Xoá dữ liệu")
        .alert("Xoá tất cả dữ liệu?", isPresented: $showResetAllAlert) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá tất cả", role: .destructive) {
                progressStore.clearAllProgress()
                Haptics.notification(.success)
                // Full wipe returns the app to onboarding (GPLX2026App observes this flag).
                hasCompletedOnboarding = false
            }
        } message: {
            Text("Toàn bộ tiến độ học, lịch sử thi, đánh dấu và câu sai sẽ bị xoá vĩnh viễn.")
        }
        .alert(
            resetConfirmation?.title ?? "",
            isPresented: Binding(
                get: { resetConfirmation != nil },
                set: { if !$0 { resetConfirmation = nil } }
            )
        ) {
            Button("Huỷ", role: .cancel) { resetConfirmation = nil }
            Button("Xoá", role: .destructive) {
                if let action = resetConfirmation { performReset(action) }
                resetConfirmation = nil
            }
        } message: {
            Text(resetConfirmation?.message ?? "")
        }
        .overlay(alignment: .bottom) {
            if let toast {
                Text(toast)
                    .font(.appSans(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.appSuccess, in: Capsule())
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Rows

    private func divider() -> some View {
        Rectangle()
            .fill(Color(hex: 0x000000, opacity: 0.06))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func resetRow(icon: String, title: String, subtitle: String, action: ResetAction) -> some View {
        Button { resetConfirmation = action } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.appSans(size: 14))
                    .foregroundStyle(Color.appError.opacity(0.7))
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.appSans(size: 14, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                    Text(subtitle)
                        .font(.appSans(size: 12))
                        .foregroundStyle(Color.appTextLight)
                }
                Spacer()
                Image(systemName: "trash")
                    .font(.appSans(size: 12))
                    .foregroundStyle(Color.appError.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func showToast(_ message: String) {
        withAnimation(.spring(duration: 0.3)) { toast = message }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut(duration: 0.3)) { toast = nil }
        }
    }

    private func performReset(_ action: ResetAction) {
        switch action {
        case .topicProgress:      progressStore.clearTopicProgress();     showToast("Đã xoá tiến độ học")
        case .examHistory:        progressStore.clearExamHistory();        showToast("Đã xoá lịch sử thi thử")
        case .simulationHistory:  progressStore.clearSimulationHistory();  showToast("Đã xoá lịch sử mô phỏng")
        case .hazardHistory:      progressStore.clearHazardHistory();      showToast("Đã xoá lịch sử tình huống")
        case .bookmarks:          progressStore.clearBookmarks();          showToast("Đã xoá đánh dấu")
        case .wrongAnswers:       progressStore.clearWrongAnswers();       showToast("Đã xoá câu sai")
        }
        Haptics.notification(.success)
    }
}

// MARK: - Reset Action

private enum ResetAction: Identifiable {
    case topicProgress, examHistory, simulationHistory, hazardHistory, bookmarks, wrongAnswers

    var id: String {
        switch self {
        case .topicProgress:     return "topicProgress"
        case .examHistory:       return "examHistory"
        case .simulationHistory: return "simulationHistory"
        case .hazardHistory:     return "hazardHistory"
        case .bookmarks:         return "bookmarks"
        case .wrongAnswers:      return "wrongAnswers"
        }
    }

    var title: String {
        switch self {
        case .topicProgress:     return "Xoá tiến độ học?"
        case .examHistory:       return "Xoá lịch sử thi thử?"
        case .simulationHistory: return "Xoá lịch sử mô phỏng?"
        case .hazardHistory:     return "Xoá lịch sử tình huống?"
        case .bookmarks:         return "Xoá tất cả đánh dấu?"
        case .wrongAnswers:      return "Xoá danh sách câu sai?"
        }
    }

    var message: String {
        switch self {
        case .topicProgress:     return "Tiến độ tất cả chủ đề sẽ bị xoá vĩnh viễn."
        case .examHistory:       return "Toàn bộ kết quả thi thử sẽ bị xoá vĩnh viễn."
        case .simulationHistory: return "Toàn bộ kết quả mô phỏng sẽ bị xoá vĩnh viễn."
        case .hazardHistory:     return "Toàn bộ kết quả tình huống sẽ bị xoá vĩnh viễn."
        case .bookmarks:         return "Tất cả câu hỏi đã đánh dấu sẽ bị xoá."
        case .wrongAnswers:      return "Danh sách câu sai sẽ bị xoá."
        }
    }
}
