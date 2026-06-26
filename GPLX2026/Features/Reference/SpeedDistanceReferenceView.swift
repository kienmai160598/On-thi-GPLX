import SwiftUI

struct SpeedDistanceReferenceView: View {
    @Environment(LayoutMetrics.self) private var metrics
    @State private var selectedSection: SpeedSection? = nil

    private enum SpeedSection: String, CaseIterable, Identifiable {
        case speed = "Tốc độ"
        case distance = "Khoảng cách"
        case alcohol = "Nồng độ cồn"
        case rules = "Quy tắc"
        case penalty = "Mức phạt"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .speed: "gauge.with.dots.needle.67percent"
            case .distance: "arrow.left.and.right"
            case .alcohol: "hand.raised.fill"
            case .rules: "checkmark.shield.fill"
            case .penalty: "banknote"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Alcohol Warning (always on top)
                    HStack(spacing: 14) {
                        Image(systemName: "hand.raised.fill")
                            .font(.appSans(size: 22))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.appError, in: RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nghiêm cấm tuyệt đối")
                                .font(.appSans(size: 16, weight: .bold))
                                .foregroundStyle(Color.appError)
                            Text("Không được điều khiển xe khi có nồng độ cồn")
                                .font(.appSans(size: 13))
                                .foregroundStyle(Color.appTextMedium)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .glassCard()

                    // MARK: - Speed (Thông tư 38/2024, từ 01/01/2025)
                    if selectedSection == nil || selectedSection == .speed {
                        RefSection(title: "Trong đô thị (tất cả xe)", icon: "building.2", rows: [
                            .init(label: "Đường đôi / 1 chiều ≥ 2 làn", value: "60", unit: "km/h"),
                            .init(label: "Đường 2 chiều / 1 chiều 1 làn", value: "50", unit: "km/h"),
                        ])

                        RefSection(title: "Ngoài đô thị (2 chiều / 1 làn)", icon: "road.lanes", rows: [
                            .init(label: "Ô tô con, tải ≤ 3.5T", value: "80", unit: "km/h"),
                            .init(label: "Tải > 3.5T, xe buýt, khách > 28 chỗ", value: "70", unit: "km/h"),
                            .init(label: "Xe mô tô", value: "60", unit: "km/h"),
                        ])

                        RefSection(title: "Ngoài đô thị (đường đôi / 1 chiều ≥ 2 làn)", icon: "arrow.up.road.lane", rows: [
                            .init(label: "Ô tô con, tải ≤ 3.5T", value: "90", unit: "km/h"),
                            .init(label: "Tải > 3.5T, xe buýt, khách > 28 chỗ", value: "80", unit: "km/h"),
                            .init(label: "Xe mô tô", value: "70", unit: "km/h"),
                        ])

                        RefSection(title: "Trên cao tốc", icon: "car.rear.road.lane", rows: [
                            .init(label: "Tối đa (theo biển)", value: "120", unit: "km/h"),
                            .init(label: "Tối thiểu", value: "60", unit: "km/h"),
                        ])

                        RefSection(title: "Xe gắn máy (< 50cc)", icon: "bicycle", rows: [
                            .init(label: "Tốc độ tối đa", value: "40", unit: "km/h"),
                        ])
                    }

                    // MARK: - Distance
                    if selectedSection == nil || selectedSection == .distance {
                        RefSection(title: "Khoảng cách an toàn (TT 31/2019 Điều 11)", icon: "arrow.left.and.right", rows: [
                            .init(label: "Đến 60 km/h", value: "Tự giữ", unit: ""),
                            .init(label: "60–80 km/h", value: "≥ 35", unit: "m"),
                            .init(label: "80–100 km/h", value: "≥ 55", unit: "m"),
                            .init(label: "100–120 km/h", value: "≥ 70", unit: "m"),
                        ])
                    }

                    // MARK: - Alcohol
                    if selectedSection == nil || selectedSection == .alcohol {
                        RefSection(title: "Giới hạn cho phép", icon: "drop.triangle", accentColor: .appError, rows: [
                            .init(label: "Ô tô", value: "0", unit: "mg/lít khí thở", accentColor: .appError),
                            .init(label: "Xe máy", value: "0", unit: "mg/lít khí thở", accentColor: .appError),
                            .init(label: "Trong máu", value: "0", unit: "mg/dl", accentColor: .appError),
                        ])
                    }

                    // MARK: - Rules
                    if selectedSection == nil || selectedSection == .rules {
                        VStack(alignment: .leading, spacing: 10) {
                            RefSectionHeader(icon: "checkmark.shield.fill", title: "Quy tắc quan trọng")

                            VStack(spacing: 8) {
                                RuleCard(icon: "list.number", title: "Thứ tự ưu tiên điều khiển GT",
                                         detail: "CSGT → Đèn tín hiệu → Biển báo → Vạch kẻ đường")
                                RuleCard(icon: "arrow.triangle.branch", title: "Ngã tư không đèn",
                                         detail: "Nhường xe đến từ bên phải. Đường ưu tiên > Đường nhánh")
                                RuleCard(icon: "car.side", title: "Vượt xe",
                                         detail: "Chỉ vượt bên trái, trừ khi xe phía trước rẽ trái")
                                RuleCard(icon: "light.beacon.max", title: "Xe ưu tiên",
                                         detail: "Cứu hoả, cứu thương, công an, quân sự (có còi + đèn ưu tiên)")
                                RuleCard(icon: "moon.fill", title: "Ban đêm",
                                         detail: "Đèn chiếu gần trong đô thị, chuyển đèn chiếu gần khi có xe ngược chiều")
                                RuleCard(icon: "parkingsign", title: "Dừng / Đỗ xe",
                                         detail: "Cách ngã ba/tư ≥ 5m, cách bến xe buýt ≥ 20m, không đỗ trên cầu")
                                RuleCard(icon: "phone.down.fill", title: "Cấm điện thoại",
                                         detail: "Cấm sử dụng điện thoại cầm tay khi lái xe",
                                         accentColor: .appError)
                            }
                        }
                    }

                    // MARK: - Penalty
                    if selectedSection == nil || selectedSection == .penalty {
                        VStack(alignment: .leading, spacing: 10) {
                            RefSectionHeader(icon: "banknote", title: "Mức phạt ô tô (NĐ 168/2024)")

                            VStack(spacing: 0) {
                                PenaltyRow(icon: "light.max", violation: "Vượt đèn đỏ", penalty: "18–20 triệu + trừ 4 điểm")
                                Divider().padding(.leading, 16)
                                PenaltyRow(icon: "wineglass", violation: "Nồng độ cồn (cao nhất)", penalty: "30–40 triệu + trừ 12 điểm")
                                Divider().padding(.leading, 16)
                                PenaltyRow(icon: "gauge.with.dots.needle.100percent", violation: "Quá tốc độ > 35 km/h", penalty: "12–14 triệu + trừ 10 điểm")
                                Divider().padding(.leading, 16)
                                PenaltyRow(icon: "doc.text", violation: "Không có GPLX", penalty: "18–20 triệu")
                                Divider().padding(.leading, 16)
                                PenaltyRow(icon: "arrow.uturn.left", violation: "Ngược chiều cao tốc", penalty: "40–50 triệu + trừ 12 điểm")
                            }
                            .glassCard()
                        }
                    }
            }
            .padding(.horizontal, metrics.contentPadding)
            .padding(.bottom, 20)
        }
        .screenHeader("Tốc độ & Quy tắc")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        withAnimation { selectedSection = nil }
                    } label: {
                        Label("Tất cả", systemImage: selectedSection == nil ? "checkmark" : "")
                    }
                    ForEach(SpeedSection.allCases) { section in
                        Button {
                            withAnimation { selectedSection = section }
                        } label: {
                            Label(section.rawValue, systemImage: selectedSection == section ? "checkmark" : "")
                        }
                    }
                } label: {
                    Image(systemName: selectedSection != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

// MARK: - Ref Section (grouped table)

/// Shared section header (accent icon + bold title) used by every section on this
/// screen so the speed tables, rules, and penalties all read the same way.
private struct RefSectionHeader: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    let title: String
    /// nil → follow the user's configured accent.
    var accentColor: Color? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(accentColor ?? themeStore.primaryColor)
            Text(title)
                .font(.appSans(size: 15, weight: .bold))
                .foregroundStyle(Color.appTextDark)
        }
    }
}

/// One key-value row's data inside a `RefSection`. `accentColor` nil → accent.
private struct RefRowSpec {
    let label: String
    let value: String
    let unit: String
    var accentColor: Color? = nil
}

private struct RefSection: View {
    let title: String
    let icon: String
    var accentColor: Color? = nil
    let rows: [RefRowSpec]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RefSectionHeader(icon: icon, title: title, accentColor: accentColor)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    RefRow(row.label, value: row.value, unit: row.unit, accentColor: row.accentColor)
                    if index < rows.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .glassCard()
        }
    }
}

// MARK: - Ref Row (key-value inside a section)

private struct RefRow: View {
    @Environment(ThemeStore.self) private var themeStore
    let label: String
    let value: String
    let unit: String
    var accentColor: Color? = nil

    init(_ label: String, value: String, unit: String, accentColor: Color? = nil) {
        self.label = label
        self.value = value
        self.unit = unit
        self.accentColor = accentColor
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.appSans(size: 14))
                .foregroundStyle(Color.appTextDark)
            Spacer()
            HStack(spacing: 4) {
                Text(value)
                    .font(.appSans(size: 16, weight: .bold))
                    .foregroundStyle(accentColor ?? themeStore.primaryColor)
                Text(unit)
                    .font(.appSans(size: 12))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Rule Card

private struct RuleCard: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    let title: String
    let detail: String
    var accentColor: Color? = nil

    var body: some View {
        let accent = accentColor ?? themeStore.primaryColor
        return HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.appSans(size: 15))
                .foregroundStyle(accent)
                .frame(width: 36, height: 36)
                .background(accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appSans(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                Text(detail)
                    .font(.appSans(size: 13))
                    .foregroundStyle(Color.appTextMedium)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glassCard()
    }
}

// MARK: - Penalty Row

private struct PenaltyRow: View {
    let icon: String
    let violation: String
    let penalty: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.appSans(size: 15))
                .foregroundStyle(Color.appError)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(violation)
                    .font(.appSans(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                Text(penalty)
                    .font(.appSans(size: 13))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
