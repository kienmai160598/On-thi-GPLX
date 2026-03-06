import SwiftUI

struct SettingsView: View {
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appThemeMode") private var themeMode: String = "system"
    @AppStorage("appFontSize") private var fontSize: String = "medium"
    @AppStorage("appPrimaryColor") private var primaryColorKey: String = "default"

    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Appearance
                SectionTitle(title: "Giao diện")
                ThemeModePicker(selected: $themeMode, primaryColorKey: primaryColorKey)

                // MARK: - Primary Color
                SectionTitle(title: "Màu chủ đạo")
                PrimaryColorPicker(selected: $primaryColorKey)

                // MARK: - Font Size
                SectionTitle(title: "Cỡ chữ")
                FontSizeSlider(selected: $fontSize, primaryColorKey: primaryColorKey)
                FontSizePreview(fontSize: fontSize)

                // MARK: - Data
                SectionTitle(title: "Dữ liệu")
                Button {
                    showResetConfirmation = true
                } label: {
                    SettingsTile(
                        icon: "trash",
                        title: "Xóa tiến độ",
                        iconColor: Color.appError
                    )
                    .glassCard()
                }

                // MARK: - Credits
                SectionTitle(title: "Nguồn dữ liệu")
                VStack(spacing: 0) {
                    AboutRow(icon: "doc.text", label: "Ngân hàng đề thi", value: "Bộ GTVT")
                    Divider().padding(.horizontal, 16)
                    AboutRow(icon: "video", label: "Video mô phỏng", value: "gmec.vn")
                }
                .glassCard()

                // MARK: - About
                SectionTitle(title: "Thông tin")
                VStack(spacing: 0) {
                    AboutRow(icon: "person.fill", label: "Tác giả", value: "Kien Mai")
                    Divider().padding(.horizontal, 16)
                    AboutRow(icon: "phone.fill", label: "Điện thoại", value: "0913451267")
                    Divider().padding(.horizontal, 16)
                    AboutRow(icon: "creditcard.fill", label: "Ngân hàng", value: "Techcombank")
                    Divider().padding(.horizontal, 16)
                    AboutRow(icon: "number", label: "STK", value: "686816051998")
                    Divider().padding(.horizontal, 16)
                    AboutRow(icon: "info.circle.fill", label: "Phiên bản", value: "1.0.0")
                }
                .glassCard()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .screenHeader("Cài đặt")
        .alert("Xóa tiến độ?", isPresented: $showResetConfirmation) {
            Button("Hủy", role: .cancel) {}
            Button("Xóa", role: .destructive) {
                progressStore.clearAllProgress()
            }
        } message: {
            Text("Tất cả tiến độ học, lịch sử thi và đánh dấu sẽ bị xóa.")
        }
    }
}

// MARK: - About Row

private struct AboutRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
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
}

// MARK: - Settings Tile

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

// MARK: - Font Size Slider

private struct FontSizeSlider: View {
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

            Slider(
                value: Binding(
                    get: { currentIndex },
                    set: { selected = Self.steps[Int($0.rounded())] }
                ),
                in: 0...2,
                step: 1
            )
            .tint(Color.primaryColor(for: primaryColorKey))

            Text("A")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.appTextMedium)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassCard()
    }
}

// MARK: - Font Size Preview

private struct FontSizePreview: View {
    let fontSize: String

    private var scale: CGFloat {
        switch fontSize {
        case "small": return 0.85
        case "large": return 1.15
        default: return 1.0
        }
    }

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
