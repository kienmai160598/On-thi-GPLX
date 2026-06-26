import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(\.dismiss) private var dismiss

    // MARK: - @AppStorage (preserved exactly)
    @AppStorage(AppConstants.StorageKey.themeMode) private var themeMode: String = "system"
    @AppStorage(AppConstants.StorageKey.fontSize) private var fontSize: String = "medium"
    @AppStorage(AppConstants.StorageKey.hapticsEnabled) private var hapticsEnabled: Bool = true
    @AppStorage(AppConstants.StorageKey.licenseType) private var licenseType: String = "b2"
    @AppStorage(AppConstants.StorageKey.dailyReminderEnabled) private var dailyReminderEnabled: Bool = false
    @AppStorage(AppConstants.StorageKey.dailyReminderHour) private var dailyReminderHour: Int = 20
    @AppStorage(AppConstants.StorageKey.examCountdownEnabled) private var examCountdownEnabled: Bool = false
    @AppStorage(AppConstants.StorageKey.dailyGoalNudgeEnabled) private var dailyGoalNudgeEnabled: Bool = false

    // MARK: - State
    @State private var showPermissionDeniedAlert = false
    @State private var showLicensePicker = false
    @State private var showDatePicker = false

    // MARK: - Body

    var body: some View {
        @Bindable var themeStore = themeStore

        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                // ── TÀI KHOẢN ──────────────────────────────────────────
                settingsSection("TÀI KHOẢN") {
                    Button { showLicensePicker = true } label: {
                        settingsNavRow(label: "Hạng giấy phép", value: licenseType.uppercased())
                    }
                    .buttonStyle(.plain)

                    settingsDivider()

                    Button { showDatePicker = true } label: {
                        settingsNavRow(label: "Ngày thi", value: progressStore.examDate.map { formatDate($0) } ?? "Chưa đặt")
                    }
                    .buttonStyle(.plain)
                }

                // ── GIAO DIỆN ──────────────────────────────────────────
                // Design SVK1N: flat inline rows (label left, control right), no icon boxes.
                settingsSection("GIAO DIỆN") {
                    inlineControlRow(label: "Giao diện") {
                        SettingsSegmentedControl(
                            segments: [
                                .init(key: "light", label: "Sáng", a11yLabel: "Giao diện sáng"),
                                .init(key: "dark", label: "Tối", a11yLabel: "Giao diện tối"),
                                .init(key: "system", label: "Tự động", a11yLabel: "Giao diện tự động"),
                            ],
                            selected: $themeMode
                        )
                        .onChange(of: themeMode) { Haptics.selection() }
                    }

                    settingsDivider()

                    inlineControlRow(label: "Cỡ chữ") {
                        SettingsSegmentedControl(
                            segments: [
                                .init(key: "small", label: "A", fontSize: 12, a11yLabel: "Cỡ chữ nhỏ"),
                                .init(key: "medium", label: "A", fontSize: 15, a11yLabel: "Cỡ chữ vừa"),
                                .init(key: "large", label: "A", fontSize: 18, a11yLabel: "Cỡ chữ lớn"),
                            ],
                            selected: $fontSize
                        )
                        .onChange(of: fontSize) { Haptics.selection() }
                    }

                    settingsDivider()

                    inlineControlRow(label: "Màu nhấn") {
                        PrimaryColorPicker(selected: $themeStore.accentKey)
                    }
                }

                // ── ỨNG DỤNG ───────────────────────────────────────────
                settingsSection("ỨNG DỤNG") {
                    settingsToggleRow(label: "Rung phản hồi", isOn: $hapticsEnabled)
                        .onChange(of: hapticsEnabled) { _, on in
                            if on { Haptics.impact(.light) }
                        }

                    settingsDivider()

                    settingsToggleRow(label: "Nhắc nhở học tập", isOn: $dailyReminderEnabled)
                        .onChange(of: dailyReminderEnabled) { _, newValue in
                            handleReminderChange(turnedOn: newValue) { dailyReminderEnabled = false }
                        }

                    settingsDivider()

                    NavigationLink(destination: OfflineDownloadView()) {
                        settingsNavRow(label: "Quản lý tải offline", value: offlineSizeText)
                    }
                    .buttonStyle(.plain)
                }

                // ── DỮ LIỆU ───────────────────────────────────────────
                settingsSection("DỮ LIỆU") {
                    NavigationLink(destination: DataManagementView()) {
                        settingsNavRow(label: "Xoá dữ liệu", value: "")
                    }
                    .buttonStyle(.plain)
                }

                // ── VỀ ỨNG DỤNG ────────────────────────────────────────
                settingsSection("VỀ ỨNG DỤNG") {
                    aboutRow(label: "Nhà phát triển", value: "Mai Trung Kiên")
                    settingsDivider()
                    aboutRow(label: "Phiên bản", value: appVersionShort)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .screenHeader("Cài đặt", titleDisplayMode: .inline, hideBackButton: true)
        // Presented full-screen (same as a question), so it provides its own
        // leading close button instead of a system back button.
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.appSans(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)
                }
                .accessibilityLabel("Đóng")
            }
        }
        .onAppear { videoCache.ensureStatsLoaded() }
        // ── Alerts ──────────────────────────────────────────────────────
        .alert("Cần quyền thông báo", isPresented: $showPermissionDeniedAlert) {
            Button("Mở Cài đặt") { openAppSettings() }
            Button("Để sau", role: .cancel) {}
        } message: {
            Text("Bật thông báo trong Cài đặt để nhận nhắc nhở ôn tập.")
        }
        // ── License picker sheet ─────────────────────────────────────────
        .sheet(isPresented: $showLicensePicker) {
            LicensePickerSheet(licenseType: $licenseType)
                .presentationDetents([.fraction(0.4)])
        }
        // ── Exam date sheet ──────────────────────────────────────────────
        .sheet(isPresented: $showDatePicker) {
            ExamDateSheet(progressStore: progressStore, onConfirm: { syncReminders() })
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Computed

    private var appVersionShort: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// Cache size shown on the "Quản lý tải offline" row (blank when nothing cached).
    private var offlineSizeText: String {
        let mb = videoCache.cacheSizeMB
        guard mb > 0 else { return "" }
        return mb >= 1024 ? String(format: "%.1f GB", mb / 1024) : String(format: "%.0f MB", mb)
    }

    private static let examDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    private func formatDate(_ date: Date) -> String {
        Self.examDateFormatter.string(from: date)
    }

    // MARK: - Reminder helpers (preserved exactly)

    private func handleReminderChange(turnedOn: Bool, resetOnDenied: @escaping () -> Void) {
        guard turnedOn else { syncReminders(); return }
        Task { @MainActor in
            if await ensureNotificationPermission() {
                syncReminders()
            } else {
                resetOnDenied()
                showPermissionDeniedAlert = true
            }
        }
    }

    private func ensureNotificationPermission() async -> Bool {
        switch await NotificationManager.authorizationStatus() {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return await NotificationManager.requestAuthorization()
        default:
            return false
        }
    }

    private func syncReminders() {
        Task { @MainActor in
            await NotificationManager.syncReminders(
                dailyEnabled: dailyReminderEnabled,
                hour: dailyReminderHour,
                examCountdownEnabled: examCountdownEnabled,
                dailyGoalNudgeEnabled: dailyGoalNudgeEnabled,
                progressStore: progressStore,
                questionStore: questionStore
            )
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Section scaffolding

    /// Section group: an eyebrow label above a translucent card (design spacing
    /// 14 between sections, 6 between eyebrow and card; card adds 2pt breathing room).
    @ViewBuilder
    private func settingsSection<Content: View>(
        _ title: String,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            settingsEyebrow(title)
            // Card padding [2,12] (design): the horizontal inset lives on the card,
            // so rows AND the hairline dividers align and the dividers stay inset
            // from the card edge (never edge-to-edge).
            VStack(spacing: 0) { content() }
                .padding(.vertical, 2)
                .padding(.horizontal, 12)
                .glassCard(cornerRadius: 20)
        }
    }

    /// A flat row with a label on the left and an inline control on the right
    /// (no icon box) — used by the GIAO DIỆN rows.
    @ViewBuilder
    private func inlineControlRow<Control: View>(
        label: String,
        @ViewBuilder _ control: () -> Control
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            control()
        }
        .padding(.vertical, 10)
    }

    // MARK: - Section components

    @ViewBuilder
    private func settingsEyebrow(_ text: String) -> some View {
        Text(text)
            .font(.appSans(size: 10, weight: .heavy))
            .foregroundStyle(Color(hex: 0x7A7166))
            .kerning(1.2)
            .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func settingsDivider() -> some View {
        Rectangle()
            .fill(Color(hex: 0x000000, opacity: 0.06))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }

    /// Plain row (design SVK1N: no icon box) — label + value + chevron.
    @ViewBuilder
    private func settingsNavRow(label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !value.isEmpty {
                Text(value)
                    .font(.appSans(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: 0x7A7166))
            }

            Image(systemName: "chevron.right")
                .font(.appSans(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0x7A7166))
        }
        // Match the toggle rows' height (the iOS switch is ~31pt) so a nav row
        // sitting next to toggles (e.g. "Quản lý tải offline") is the same height.
        .frame(minHeight: 31)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    /// Plain row with a Toggle on the right (design SVK1N: no icon box).
    @ViewBuilder
    private func settingsToggleRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(themeStore.primaryColor)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityLabel(label)
        .accessibilityValue(isOn.wrappedValue ? "Bật" : "Tắt")
        .animation(.easeOut(duration: 0.2), value: isOn.wrappedValue)
    }

    // MARK: - About Row

    @ViewBuilder
    private func aboutRow(label: String, value: String) -> some View {
        // Reversed emphasis to match the other settings rows: the label is the
        // prominent dark text, the value is muted.
        HStack(spacing: 12) {
            Text(label)
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
            Spacer()
            Text(value)
                .font(.appSans(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: 0x7A7166))
        }
        .padding(.vertical, 12)
    }
}

// MARK: - SettingsSegmentedControl (compact inline pill, design SVK1N)

private struct SettingsSegmentedControl: View {
    @Environment(ThemeStore.self) private var themeStore

    struct Segment {
        let key: String
        let label: String
        var fontSize: CGFloat = 12
        var a11yLabel: String? = nil
    }

    let segments: [Segment]
    @Binding var selected: String

    var body: some View {
        HStack(spacing: 6) {
            ForEach(segments, id: \.key) { seg in
                let isSelected = selected == seg.key
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { selected = seg.key }
                } label: {
                    Text(seg.label)
                        .font(.appSans(size: seg.fontSize, weight: .bold))
                        .foregroundStyle(isSelected ? themeStore.onPrimaryColor : Color(hex: 0x7A7166))
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background {
                            if isSelected {
                                Capsule().fill(themeStore.primaryColor)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(seg.a11yLabel ?? seg.label)
                .accessibilityValue(isSelected ? "Đã chọn" : "")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(3)
        .glassCapsuleTrack()
        // Keep the pills at their natural width so the greedy leading label can't
        // squeeze them into truncation ("Sá…", "Tự…").
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - LicensePickerSheet

private struct LicensePickerSheet: View {
    @Binding var licenseType: String
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(LicenseType.allCases, id: \.self) { type in
                    let isSelected = licenseType == type.rawValue
                    Button {
                        licenseType = type.rawValue
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Text(type.displayName)
                                .font(.appSans(size: 17, weight: .bold))
                                .foregroundStyle(isSelected ? themeStore.primaryColor : Color.appTextDark)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.description)
                                    .font(.appSans(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                                Text("\(type.questionsPerExam) câu · \(type.totalTimeSeconds / 60) phút · Đạt \(type.passThreshold)")
                                    .font(.appSans(size: 12))
                                    .foregroundStyle(Color.appTextLight)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.appSans(size: 14, weight: .bold))
                                    .foregroundStyle(themeStore.primaryColor)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .glassCard(cornerRadius: 16)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .navigationTitle("Hạng giấy phép")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                        .font(.appSans(size: 15, weight: .medium))
                        .foregroundStyle(themeStore.primaryColor)
                }
            }
        }
    }
}

// MARK: - ExamDateSheet

private struct ExamDateSheet: View {
    let progressStore: ProgressStore
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore

    @State private var selectedDate: Date

    init(progressStore: ProgressStore, onConfirm: @escaping () -> Void) {
        self.progressStore = progressStore
        self.onConfirm = onConfirm
        _selectedDate = State(initialValue: progressStore.examDate ?? Date().addingTimeInterval(30 * 86400))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Ngày thi dự kiến",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(themeStore.primaryColor)
                .padding(.horizontal, 20)

                if progressStore.examDate != nil {
                    Button {
                        progressStore.setExamDate(nil)
                        onConfirm()
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.minus")
                                .font(.appSans(size: 15))
                            Text("Xoá ngày thi")
                                .font(.appSans(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(Color.appError)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.top, 8)
            .navigationTitle("Ngày thi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ") { dismiss() }
                        .font(.appSans(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        progressStore.setExamDate(selectedDate)
                        onConfirm()
                        dismiss()
                    }
                    .font(.appSans(size: 15, weight: .bold))
                    .foregroundStyle(themeStore.primaryColor)
                }
            }
        }
    }
}

// MARK: - Font Scale Helper

enum AppFontScale {
    static func scale(for key: String) -> CGFloat {
        switch key {
        case "small": return 0.85
        case "large": return 1.15
        default:      return 1.0
        }
    }

    static var current: CGFloat {
        scale(for: UserDefaults.standard.string(forKey: AppConstants.StorageKey.fontSize) ?? "medium")
    }
}
