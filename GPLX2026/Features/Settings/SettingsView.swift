import SwiftUI

struct SettingsView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @AppStorage(AppConstants.StorageKey.themeMode) private var themeMode: String = "system"
    @AppStorage(AppConstants.StorageKey.fontSize) private var fontSize: String = "medium"
    @AppStorage(AppConstants.StorageKey.primaryColor) private var primaryColorKey: String = "default"
    @AppStorage(AppConstants.StorageKey.hapticsEnabled) private var hapticsEnabled: Bool = true
    @AppStorage(AppConstants.StorageKey.backgroundAnimation) private var backgroundAnimation: String = "none"
    @AppStorage(AppConstants.StorageKey.backgroundSpeed) private var backgroundSpeed: String = "normal"
    @AppStorage(AppConstants.StorageKey.dailyReminderEnabled) private var dailyReminderEnabled: Bool = false
    @AppStorage(AppConstants.StorageKey.dailyReminderHour) private var dailyReminderHour: Int = 20

    @State private var showResetSheet = false
    @State private var resetToast: String?
    @State private var showAppearanceSheet = false
    @State private var resetConfirmation: ResetAction?
    @State private var showClearCacheAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // ──────────────────────────────────────────────
                // MARK: - Giao diện (Appearance)
                // ──────────────────────────────────────────────

                settingsSection("Giao diện", subtitle: "Tuỳ chỉnh giao diện ứng dụng") {
                    ThemeModePicker(selected: $themeMode, primaryColorKey: primaryColorKey)

                    // Primary Color
                    settingsLabel("Màu chủ đạo")
                    PrimaryColorPicker(selected: $primaryColorKey)

                    // Font Size
                    settingsLabel("Cỡ chữ câu hỏi")
                    FontSizeSlider(selected: $fontSize, primaryColorKey: primaryColorKey)
                    FontSizePreview(fontSize: fontSize)

                    // Background Animation — compact row that opens sheet
                    Button { showAppearanceSheet = true } label: {
                        HStack(spacing: 12) {
                            Image(systemName: backgroundAnimation == "none" ? "sparkles" : "wand.and.stars")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.appPrimary)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hiệu ứng nền")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.appTextDark)
                                Text("Hoạt ảnh phía sau nội dung")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.appTextMedium)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .glassCard()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hiệu ứng nền: \(backgroundAnimationLabel)")

                    // Haptics toggle
                    settingsToggle(
                        iconOn: "iphone.radiowaves.left.and.right",
                        iconOff: "iphone.slash",
                        title: "Rung phản hồi",
                        subtitle: "Rung nhẹ khi chọn đáp án",
                        isOn: $hapticsEnabled
                    )
                }

                // ──────────────────────────────────────────────
                // MARK: - Kế hoạch ôn thi (Study Plan)
                // ──────────────────────────────────────────────

                settingsSection("Nhắc nhở & Mục tiêu", subtitle: "Đặt lịch ôn tập và theo dõi tiến độ") {
                    VStack(spacing: 12) {
                        // Reminder toggle
                        settingsToggle(
                            iconOn: "bell.badge.fill",
                            iconOff: "bell.slash",
                            title: "Nhắc luyện tập",
                            subtitle: "Thông báo nhắc ôn bài mỗi ngày",
                            isOn: $dailyReminderEnabled
                        )
                        .onChange(of: dailyReminderEnabled) {
                            if dailyReminderEnabled {
                                Task {
                                    let granted = await NotificationManager.requestPermission()
                                    if granted {
                                        NotificationManager.scheduleDailyReminder(hour: dailyReminderHour)
                                    } else {
                                        dailyReminderEnabled = false
                                    }
                                }
                            } else {
                                NotificationManager.cancelDailyReminder()
                            }
                        }

                        if dailyReminderEnabled {
                            HStack(spacing: 14) {
                                Image(systemName: "clock")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.appPrimary)
                                    .frame(width: 22)

                                Text("Giờ nhắc")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.appTextDark)

                                Spacer()

                                Picker("", selection: $dailyReminderHour) {
                                    ForEach(6..<24, id: \.self) { hour in
                                        Text("\(hour):00").tag(hour)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.primaryColor(for: primaryColorKey))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .glassCard()
                            .onChange(of: dailyReminderHour) {
                                NotificationManager.scheduleDailyReminder(hour: dailyReminderHour)
                            }
                        }

                        // Exam date
                        VStack(alignment: .leading, spacing: 8) {
                            DatePicker(
                                "Ngày thi dự kiến",
                                selection: Binding(
                                    get: { progressStore.examDate ?? Calendar.current.date(byAdding: .day, value: 30, to: Date())! },
                                    set: { progressStore.setExamDate($0) }
                                ),
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appTextDark)

                            Text("Hiển thị đếm ngược trên trang chủ")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.appTextMedium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .glassCard()

                        if progressStore.examDate != nil {
                            Button {
                                progressStore.setExamDate(nil)
                                Haptics.notification(.success)
                                showToast("Đã xoá ngày thi")
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.minus")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.appError)
                                        .frame(width: 22)
                                    Text("Xoá ngày thi")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color.appError)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .glassCard()
                            }
                            .buttonStyle(.plain)
                        }

                        // Daily goal
                        VStack(alignment: .leading, spacing: 8) {
                            Stepper(
                                "Mục tiêu: \(progressStore.dailyGoal) câu/ngày",
                                value: Binding(
                                    get: { progressStore.dailyGoal },
                                    set: { progressStore.setDailyGoal($0) }
                                ),
                                in: 10...100,
                                step: 10
                            )
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appTextDark)

                            Text("Theo dõi tiến độ ôn tập hằng ngày")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.appTextMedium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .glassCard()
                    }
                    .animation(.easeOut(duration: 0.2), value: dailyReminderEnabled)
                }

                // ──────────────────────────────────────────────
                // MARK: - Video offline
                // ──────────────────────────────────────────────

                settingsSection("Video tình huống", subtitle: "Tải video để xem không cần mạng") {
                    VideoOfflineCard(videoCache: videoCache, showClearAlert: $showClearCacheAlert)
                }

                // ──────────────────────────────────────────────
                // MARK: - Dữ liệu (Data)
                // ──────────────────────────────────────────────

                settingsSection("Quản lý dữ liệu", subtitle: "Xoá dữ liệu đã lưu trên máy") {
                    VStack(spacing: 0) {
                        resetRow(icon: "book.closed", title: "Tiến độ học", subtitle: "Xoá tiến độ tất cả chủ đề", action: .topicProgress)
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "doc.text", title: "Lịch sử thi thử", subtitle: "Xoá kết quả thi thử", action: .examHistory)
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "photo.on.rectangle", title: "Lịch sử mô phỏng", subtitle: "Xoá kết quả mô phỏng", action: .simulationHistory)
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "play.rectangle", title: "Lịch sử tình huống", subtitle: "Xoá kết quả tình huống", action: .hazardHistory)
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "bookmark", title: "Đánh dấu", subtitle: "Xoá tất cả đánh dấu", action: .bookmarks)
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "xmark.circle", title: "Câu sai", subtitle: "Xoá danh sách câu sai", action: .wrongAnswers)
                    }
                    .glassCard()

                    // Nuclear reset
                    Button { showResetSheet = true } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.appError)
                                .frame(width: 22)
                            Text("Xoá tất cả dữ liệu")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.appError)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.appError.opacity(0.05))
                        .glassCard()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Xoá tất cả dữ liệu")
                    .accessibilityHint("Xoá toàn bộ tiến độ học, lịch sử thi và đánh dấu")
                }

                // ──────────────────────────────────────────────
                // MARK: - Ủng hộ (Support the developer)
                // ──────────────────────────────────────────────

                settingsSection("Ủng hộ tác giả") {
                    VStack(spacing: 0) {
                        copyableRow(icon: "building.columns", label: "Ngân hàng", value: "Techcombank")
                        Divider().padding(.horizontal, 16)
                        copyableRow(icon: "person", label: "Chủ TK", value: "Kien Mai")
                        Divider().padding(.horizontal, 16)
                        copyableRow(icon: "number", label: "STK", value: "686816051998")
                    }
                    .glassCard()

                    Text("Nếu bạn thấy ứng dụng hữu ích, bạn có thể ủng hộ tác giả qua chuyển khoản.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextLight)
                        .lineSpacing(3)
                }

                // ──────────────────────────────────────────────
                // MARK: - Thông tin (About)
                // ──────────────────────────────────────────────

                settingsSection("Giới thiệu") {
                    VStack(spacing: 0) {
                        aboutRow(icon: "doc.text.fill", label: "Ngân hàng đề thi", value: "Bộ GTVT")
                        Divider().padding(.horizontal, 16)
                        aboutRow(icon: "video.fill", label: "Video mô phỏng", value: "gmec.vn")
                        Divider().padding(.horizontal, 16)
                        aboutRow(icon: "person.fill", label: "Tác giả", value: "Kien Mai")
                        Divider().padding(.horizontal, 16)
                        aboutRow(icon: "phone.fill", label: "Liên hệ", value: "0913451267")
                        Divider().padding(.horizontal, 16)
                        aboutRow(icon: "info.circle.fill", label: "Phiên bản", value: appVersion)
                        Divider().padding(.horizontal, 16)
                        aboutRow(icon: "shield.fill", label: "Quyền riêng tư", value: "Dữ liệu lưu trên máy")
                        Divider().padding(.horizontal, 16)
                        aboutRow(icon: "exclamationmark.circle.fill", label: "Miễn trừ", value: "Không phải tài liệu chính thức")
                    }
                    .glassCard()

                    Text("Ứng dụng chỉ mang tính chất tham khảo và luyện tập. Đề thi chính thức do Bộ GTVT ban hành.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextLight)
                        .lineSpacing(3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .screenHeader("Cài đặt")
        .alert("Xoá tất cả dữ liệu?", isPresented: $showResetSheet) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá tất cả", role: .destructive) {
                progressStore.clearAllProgress()
                Haptics.notification(.success)
                showToast("Đã xoá tất cả dữ liệu")
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
                if let action = resetConfirmation {
                    performReset(action)
                }
                resetConfirmation = nil
            }
        } message: {
            Text(resetConfirmation?.message ?? "")
        }
        .alert("Xoá cache video?", isPresented: $showClearCacheAlert) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá", role: .destructive) {
                videoCache.clearCache()
                Haptics.notification(.success)
                showToast("Đã xoá cache video")
            }
        } message: {
            Text("Tất cả video đã tải sẽ bị xoá. Bạn có thể tải lại sau.")
        }
        .sheet(isPresented: $showAppearanceSheet) {
            BackgroundAnimationSheet(
                selected: $backgroundAnimation,
                speedKey: $backgroundSpeed,
                primaryColorKey: primaryColorKey
            )
            .presentationDetents([.medium])
        }
        .overlay(alignment: .bottom) {
            if let toast = resetToast {
                Text(toast)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.appSuccess, in: Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Helpers

    private var backgroundAnimationLabel: String {
        switch backgroundAnimation {
        case "bubbles": return "Bong bóng"
        case "waves": return "Sóng"
        default: return "Tắt"
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func showToast(_ message: String) {
        withAnimation(.spring(duration: 0.3)) {
            resetToast = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.3)) {
                resetToast = nil
            }
        }
    }

    private func performReset(_ action: ResetAction) {
        switch action {
        case .topicProgress:
            progressStore.clearTopicProgress()
            showToast("Đã xoá tiến độ học")
        case .examHistory:
            progressStore.clearExamHistory()
            showToast("Đã xoá lịch sử thi thử")
        case .simulationHistory:
            progressStore.clearSimulationHistory()
            showToast("Đã xoá lịch sử mô phỏng")
        case .hazardHistory:
            progressStore.clearHazardHistory()
            showToast("Đã xoá lịch sử tình huống")
        case .bookmarks:
            progressStore.clearBookmarks()
            showToast("Đã xoá đánh dấu")
        case .wrongAnswers:
            progressStore.clearWrongAnswers()
            showToast("Đã xoá câu sai")
        }
        Haptics.notification(.success)
    }

    // MARK: - Section Builder

    @ViewBuilder
    private func settingsSection(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                }
            }

            content()
        }
    }

    @ViewBuilder
    private func settingsLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.appTextMedium)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    // MARK: - Settings Toggle

    @ViewBuilder
    private func settingsToggle(iconOn: String, iconOff: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: isOn.wrappedValue ? iconOn : iconOff)
                .font(.system(size: 18))
                .foregroundStyle(isOn.wrappedValue ? Color.appPrimary : Color.appTextLight)
                .frame(width: 22)
                .contentTransition(.symbolEffect(.replace))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.primaryColor(for: primaryColorKey))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard()
        .accessibilityLabel(title)
        .accessibilityValue(isOn.wrappedValue ? "Bật" : "Tắt")
        .animation(.easeOut(duration: 0.2), value: isOn.wrappedValue)
    }

    // MARK: - Reset Row

    @ViewBuilder
    private func resetRow(icon: String, title: String, subtitle: String, action: ResetAction) -> some View {
        Button {
            resetConfirmation = action
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appError.opacity(0.7))
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appTextLight)
                }
                Spacer()
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appError.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - About Row

    @ViewBuilder
    private func aboutRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextLight)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextMedium)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.appTextDark)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Copyable Row

    @ViewBuilder
    private func copyableRow(icon: String, label: String, value: String) -> some View {
        Button {
            UIPasteboard.general.string = value
            Haptics.notification(.success)
            showToast("Đã sao chép \(label)")
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextLight)
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextMedium)
                Spacer()
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.appTextDark)
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextLight)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label): \(value)")
        .accessibilityHint("Nhấn để sao chép")
    }
}

// MARK: - Reset Action

private enum ResetAction: Identifiable {
    case topicProgress
    case examHistory
    case simulationHistory
    case hazardHistory
    case bookmarks
    case wrongAnswers

    var id: String {
        switch self {
        case .topicProgress: return "topicProgress"
        case .examHistory: return "examHistory"
        case .simulationHistory: return "simulationHistory"
        case .hazardHistory: return "hazardHistory"
        case .bookmarks: return "bookmarks"
        case .wrongAnswers: return "wrongAnswers"
        }
    }

    var title: String {
        switch self {
        case .topicProgress: return "Xoá tiến độ học?"
        case .examHistory: return "Xoá lịch sử thi thử?"
        case .simulationHistory: return "Xoá lịch sử mô phỏng?"
        case .hazardHistory: return "Xoá lịch sử tình huống?"
        case .bookmarks: return "Xoá tất cả đánh dấu?"
        case .wrongAnswers: return "Xoá danh sách câu sai?"
        }
    }

    var message: String {
        switch self {
        case .topicProgress: return "Tiến độ tất cả chủ đề sẽ bị xoá vĩnh viễn."
        case .examHistory: return "Toàn bộ kết quả thi thử sẽ bị xoá vĩnh viễn."
        case .simulationHistory: return "Toàn bộ kết quả mô phỏng sẽ bị xoá vĩnh viễn."
        case .hazardHistory: return "Toàn bộ kết quả tình huống sẽ bị xoá vĩnh viễn."
        case .bookmarks: return "Tất cả câu hỏi đã đánh dấu sẽ bị xoá."
        case .wrongAnswers: return "Danh sách câu sai sẽ bị xoá."
        }
    }
}

// MARK: - Background Animation Sheet

private struct BackgroundAnimationSheet: View {
    @Binding var selected: String
    @Binding var speedKey: String
    var primaryColorKey: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Chọn hiệu ứng nền và tốc độ hiển thị.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)

                    BackgroundAnimationPicker(
                        selected: $selected,
                        speedKey: $speedKey,
                        primaryColorKey: primaryColorKey
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationTitle("Hiệu ứng nền")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .background(Color.scaffoldBg.ignoresSafeArea())
        }
    }
}

// MARK: - Font Size Slider

struct FontSizeSlider: View {
    @Binding var selected: String
    var primaryColorKey: String

    private static let steps = ["small", "medium", "large"]

    private var currentIndex: Double {
        Double(Self.steps.firstIndex(of: selected) ?? 1)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("A")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)
                .accessibilityLabel("Nhỏ")

            Slider(
                value: Binding(
                    get: { currentIndex },
                    set: { selected = Self.steps[Int($0.rounded())] }
                ),
                in: 0...2,
                step: 1
            )
            .tint(Color.primaryColor(for: primaryColorKey))
            .accessibilityLabel("Cỡ chữ câu hỏi")
            .accessibilityValue(sizeLabel)

            Text("A")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.appTextMedium)
                .accessibilityLabel("Lớn")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard()
        .onChange(of: selected) {
            Haptics.selection()
        }
    }

    private var sizeLabel: String {
        switch selected {
        case "small": return "Nhỏ"
        case "large": return "Lớn"
        default: return "Vừa"
        }
    }
}

// MARK: - Font Size Preview

private struct FontSizePreview: View {
    let fontSize: String

    private var scale: CGFloat { AppFontScale.scale(for: fontSize) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "eye")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextLight)
                Text("Xem trước")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextLight)
            }

            Text("Khi điều khiển xe trên đường mà tầm nhìn bị hạn chế, người lái xe cần giảm tốc độ và chú ý quan sát.")
                .font(.system(size: 15 * scale))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(4)
        }
        .padding(12)
        .glassCard()
    }
}

// MARK: - Font Scale Helper

enum AppFontScale {
    static func scale(for key: String) -> CGFloat {
        switch key {
        case "small": return 0.85
        case "large": return 1.15
        default: return 1.0
        }
    }

    static var current: CGFloat {
        scale(for: UserDefaults.standard.string(forKey: AppConstants.StorageKey.fontSize) ?? "medium")
    }
}

// MARK: - Settings Tile (kept for external use)

// MARK: - Video Offline Card

private struct VideoOfflineCard: View {
    let videoCache: HazardVideoCache
    @Binding var showClearAlert: Bool
    @State private var showChapters = false

    var body: some View {
        let cached = videoCache.cachedCount
        let total = videoCache.totalCount
        let fraction = total > 0 ? Double(cached) / Double(total) : 0
        let allComplete = cached == total

        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: allComplete ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.appPrimary)
                        .symbolRenderingMode(.hierarchical)
                    Text("Video offline")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Spacer()
                    Text(String(format: "%.0f MB", videoCache.cacheSizeMB))
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color.appTextLight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    ProgressBarView(fraction: fraction, color: .appPrimary, height: 6)
                    Text("\(cached)/\(total) video đã tải")
                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color.appTextMedium)
                }

                HStack(spacing: 10) {
                    if videoCache.isDownloadingAll {
                        Button {
                            videoCache.cancelAll()
                            Haptics.impact(.medium)
                        } label: {
                            HStack(spacing: 6) {
                                ProgressView().scaleEffect(0.7).tint(Color.appPrimary)
                                Text(videoCache.downloadSpeedMBps > 0
                                     ? String(format: "%.1f MB/s (Huỷ)", videoCache.downloadSpeedMBps)
                                     : "Đang tải... (Huỷ)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.appPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .glassCard(cornerRadius: 18)
                        }
                    } else if !allComplete {
                        Button {
                            Haptics.impact(.medium)
                            Task { await videoCache.downloadAll() }
                        } label: {
                            AppButton(icon: "icloud.and.arrow.down", label: "Tải tất cả", height: 36, cornerRadius: 18)
                        }
                    }

                    if cached > 0 && !videoCache.isDownloading {
                        Button { showClearAlert = true } label: {
                            AppButton(label: "Xoá", style: .secondary, height: 36, cornerRadius: 18)
                        }
                        .frame(width: 80)
                    }
                }

                if !allComplete {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showChapters.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(showChapters ? "Ẩn chi tiết" : "Tải theo chương")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.appPrimary)
                            Image(systemName: showChapters ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                }
            }
            .padding(16)

            if showChapters && !allComplete {
                Divider().padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(HazardSituation.chapters, id: \.id) { chapter in
                        let chCached = videoCache.cachedCount(forChapter: chapter.id)
                        let chTotal = videoCache.totalCount(forChapter: chapter.id)
                        let chComplete = chCached == chTotal
                        let isDownloading = videoCache.downloadingChapters.contains(chapter.id)

                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ch. \(chapter.id): \(chapter.name)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(1)
                                HStack(spacing: 4) {
                                    Text("\(chCached)/\(chTotal) video")
                                        .font(.system(size: 11, weight: .medium).monospacedDigit())
                                        .foregroundStyle(chComplete ? Color.appPrimary : Color.appTextLight)
                                    if isDownloading && videoCache.downloadSpeedMBps > 0 {
                                        Text(String(format: "· %.1f MB/s", videoCache.downloadSpeedMBps))
                                            .font(.system(size: 11, weight: .medium).monospacedDigit())
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                }
                            }

                            Spacer(minLength: 4)

                            Button {
                                Haptics.impact(.light)
                                if isDownloading {
                                    videoCache.cancelChapter(chapter.id)
                                } else {
                                    Task { await videoCache.downloadChapter(chapter.id) }
                                }
                            } label: {
                                Group {
                                    if isDownloading {
                                        ProgressView().scaleEffect(0.65).tint(Color.appPrimary)
                                    } else if chComplete {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.appPrimary)
                                    } else {
                                        Image(systemName: "icloud.and.arrow.down")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                }
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                            }
                            .disabled(chComplete && !isDownloading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        if chapter.id < HazardSituation.chapters.last?.id ?? 0 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .glassCard()
    }
}

struct SettingsTile: View {
    let icon: String
    let title: String
    var iconColor: Color = Color.appTextMedium

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 22)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appTextDark)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
