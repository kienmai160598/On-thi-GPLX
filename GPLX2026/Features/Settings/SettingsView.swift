import SwiftUI

struct SettingsView: View {
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appThemeMode") private var themeMode: String = "system"
    @AppStorage("appFontSize") private var fontSize: String = "medium"
    @AppStorage("appPrimaryColor") private var primaryColorKey: String = "default"
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("backgroundAnimation") private var backgroundAnimation: String = "none"
    @AppStorage("backgroundSpeed") private var backgroundSpeed: String = "normal"

    @State private var showResetSheet = false
    @State private var resetToast: String?
    @State private var showAppearanceSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // ──────────────────────────────────────────────
                // MARK: - Giao diện (Appearance)
                // ──────────────────────────────────────────────

                settingsSection("Giao diện") {
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
                                Text(backgroundAnimationLabel)
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
                }

                // ──────────────────────────────────────────────
                // MARK: - Tương tác (Interaction)
                // ──────────────────────────────────────────────

                settingsSection("Tương tác") {
                    // Haptics toggle
                    HStack(spacing: 14) {
                        Image(systemName: hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                            .font(.system(size: 18))
                            .foregroundStyle(hapticsEnabled ? Color.appPrimary : Color.appTextLight)
                            .frame(width: 22)
                            .contentTransition(.symbolEffect(.replace))

                        Text("Rung phản hồi")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appTextDark)

                        Spacer()

                        Toggle("", isOn: $hapticsEnabled)
                            .labelsHidden()
                            .tint(Color.primaryColor(for: primaryColorKey))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassCard()
                    .accessibilityLabel("Rung phản hồi")
                    .accessibilityValue(hapticsEnabled ? "Bật" : "Tắt")
                    .animation(.easeOut(duration: 0.2), value: hapticsEnabled)
                }

                // ──────────────────────────────────────────────
                // MARK: - Dữ liệu (Data)
                // ──────────────────────────────────────────────

                settingsSection("Dữ liệu") {
                    VStack(spacing: 0) {
                        resetRow(icon: "book.closed", title: "Tiến độ học", subtitle: "Xoá tiến độ tất cả chủ đề") {
                            progressStore.clearTopicProgress()
                        }
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "doc.text", title: "Lịch sử thi thử", subtitle: "Xoá kết quả thi thử") {
                            progressStore.clearExamHistory()
                        }
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "photo.on.rectangle", title: "Lịch sử mô phỏng", subtitle: "Xoá kết quả mô phỏng") {
                            progressStore.clearSimulationHistory()
                        }
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "play.rectangle", title: "Lịch sử tình huống", subtitle: "Xoá kết quả tình huống") {
                            progressStore.clearHazardHistory()
                        }
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "bookmark", title: "Đánh dấu", subtitle: "Xoá tất cả đánh dấu") {
                            progressStore.clearBookmarks()
                        }
                        Divider().padding(.horizontal, 16)
                        resetRow(icon: "xmark.circle", title: "Câu sai", subtitle: "Xoá danh sách câu sai") {
                            progressStore.clearWrongAnswers()
                        }
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
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nếu bạn thấy ứng dụng hữu ích, bạn có thể ủng hộ tác giả qua chuyển khoản.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.appTextMedium)
                            .lineSpacing(3)

                        VStack(spacing: 0) {
                            copyableRow(icon: "building.columns", label: "Ngân hàng", value: "Techcombank")
                            Divider().padding(.horizontal, 16)
                            copyableRow(icon: "person", label: "Chủ TK", value: "Kien Mai")
                            Divider().padding(.horizontal, 16)
                            copyableRow(icon: "number", label: "STK", value: "686816051998")
                        }
                        .glassCard()
                    }
                }

                // ──────────────────────────────────────────────
                // MARK: - Thông tin (About)
                // ──────────────────────────────────────────────

                settingsSection("Thông tin") {
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
                    }
                    .glassCard()
                }

                // ──────────────────────────────────────────────
                // MARK: - Pháp lý (Legal)
                // ──────────────────────────────────────────────

                settingsSection("Pháp lý") {
                    VStack(spacing: 0) {
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

    // MARK: - Section Builder

    @ViewBuilder
    private func settingsSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

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

    // MARK: - Reset Row

    @ViewBuilder
    private func resetRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            Haptics.notification(.success)
            showToast("Đã xoá \(title.lowercased())")
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextLight)
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
        .padding(16)
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
        scale(for: UserDefaults.standard.string(forKey: "appFontSize") ?? "medium")
    }
}

// MARK: - Settings Tile (kept for external use)

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
