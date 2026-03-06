import SwiftUI

struct SettingsView: View {
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appThemeMode") private var themeMode: String = "system"
    @AppStorage("appFontSize") private var fontSize: String = "medium"
    @AppStorage("appPrimaryColor") private var primaryColorKey: String = "default"

    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Appearance Section
                SectionTitle(title: "Giao diện")
                    .padding(.bottom, 10)
                    .staggered(0)

                ThemeModePicker(selected: $themeMode, primaryColorKey: primaryColorKey)
                    .padding(.bottom, 24)
                    .staggered(1)

                // MARK: - Primary Color
                SectionTitle(title: "Màu chủ đạo")
                    .padding(.bottom, 10)
                    .staggered(2)

                PrimaryColorPicker(selected: $primaryColorKey)
                    .padding(.bottom, 24)
                    .staggered(3)

                // MARK: - Font Size
                SectionTitle(title: "Cỡ chữ")
                    .padding(.bottom, 10)
                    .staggered(4)

                FontSizeSlider(selected: $fontSize, primaryColorKey: primaryColorKey)
                    .padding(.bottom, 12)
                    .staggered(5)

                FontSizePreview(fontSize: fontSize)
                    .padding(.bottom, 24)
                    .staggered(6)

                // MARK: - Data Section
                SectionTitle(title: "Dữ liệu")
                    .padding(.bottom, 10)
                    .staggered(7)

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
                .padding(.bottom, 24)
                .staggered(8)

                // MARK: - Credits Section
                SectionTitle(title: "Nguồn dữ liệu")
                    .padding(.bottom, 10)
                    .staggered(9)

                VStack(spacing: 0) {
                    AboutRow(icon: "doc.text", label: "Ngân hàng đề thi", value: "Bộ GTVT")
                    Divider().padding(.horizontal, 16)
                    AboutRow(icon: "video", label: "Video mô phỏng", value: "gmec.vn")
                }
                .glassCard()
                .padding(.bottom, 24)
                .staggered(10)

                // MARK: - About Section
                SectionTitle(title: "Thông tin")
                    .padding(.bottom, 10)
                    .staggered(11)

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
            .padding(.bottom, 20)
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
    var trailing: AnyView? = nil

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

            if let trailing = trailing {
                trailing
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
        .padding(.vertical, 8)
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
                    .tracking(0.3)
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

