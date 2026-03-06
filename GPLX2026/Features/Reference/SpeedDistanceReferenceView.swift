import SwiftUI

struct SpeedDistanceReferenceView: View {
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
            VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Alcohol Warning (always on top)
                    HStack(spacing: 12) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.appError, in: RoundedRectangle(cornerRadius: 11))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nghiêm cấm tuyệt đối")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundStyle(Color.appError)
                            Text("Không được điều khiển xe khi có nồng độ cồn")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.appTextMedium)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .glassCard()

                    // MARK: - Speed (Thông tư 38/2024, từ 01/01/2025)
                    if selectedSection == nil || selectedSection == .speed {
                        RefSection(title: "Trong đô thị (tất cả xe)", icon: "building.2") {
                            RefRow("Đường đôi / 1 chiều ≥ 2 làn", value: "60", unit: "km/h")
                            RefRow("Đường 2 chiều / 1 chiều 1 làn", value: "50", unit: "km/h")
                        }

                        RefSection(title: "Ngoài đô thị (2 chiều / 1 làn)", icon: "road.lanes") {
                            RefRow("Ô tô con, tải ≤ 3.5T", value: "80", unit: "km/h")
                            RefRow("Tải > 3.5T, xe buýt, khách > 28 chỗ", value: "70", unit: "km/h")
                            RefRow("Xe mô tô", value: "60", unit: "km/h")
                        }

                        RefSection(title: "Ngoài đô thị (đường đôi / 1 chiều ≥ 2 làn)", icon: "arrow.up.road.lane") {
                            RefRow("Ô tô con, tải ≤ 3.5T", value: "90", unit: "km/h")
                            RefRow("Tải > 3.5T, xe buýt, khách > 28 chỗ", value: "80", unit: "km/h")
                            RefRow("Xe mô tô", value: "70", unit: "km/h")
                        }

                        RefSection(title: "Trên cao tốc", icon: "car.rear.road.lane") {
                            RefRow("Tối đa (theo biển)", value: "120", unit: "km/h")
                            RefRow("Tối thiểu", value: "60", unit: "km/h")
                        }

                        RefSection(title: "Xe gắn máy (< 50cc)", icon: "bicycle") {
                            RefRow("Tốc độ tối đa", value: "40", unit: "km/h")
                        }
                    }

                    // MARK: - Distance
                    if selectedSection == nil || selectedSection == .distance {
                        RefSection(title: "Khoảng cách an toàn (TT 38/2024)", icon: "arrow.left.and.right") {
                            RefRow("60 km/h", value: "≥ 35", unit: "m")
                            RefRow("60–80 km/h", value: "≥ 55", unit: "m")
                            RefRow("80–100 km/h", value: "≥ 70", unit: "m")
                            RefRow("100–120 km/h", value: "≥ 100", unit: "m")
                            RefRow("Dưới 60 km/h", value: "Tự giữ", unit: "khoảng cách")
                        }
                    }

                    // MARK: - Alcohol
                    if selectedSection == nil || selectedSection == .alcohol {
                        VStack(spacing: 10) {
                            RefSection(title: "Giới hạn cho phép", icon: "drop.triangle", accentColor: .appError) {
                                RefRow("Ô tô", value: "0", unit: "mg/lít khí thở", accentColor: .appError)
                                RefRow("Xe máy", value: "0", unit: "mg/lít khí thở", accentColor: .appError)
                                RefRow("Trong máu", value: "0", unit: "mg/dl", accentColor: .appError)
                            }
                        }
                    }

                    // MARK: - Rules
                    if selectedSection == nil || selectedSection == .rules {
                        SectionTitle(title: "Quy tắc quan trọng")

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

                    // MARK: - Penalty
                    if selectedSection == nil || selectedSection == .penalty {
                        SectionTitle(title: "Mức phạt ô tô (NĐ 168/2024)")

                        VStack(spacing: 0) {
                            PenaltyRow(icon: "light.max", violation: "Vượt đèn đỏ", penalty: "18–20 triệu + trừ 4 điểm")
                            Divider().padding(.horizontal, 16)
                            PenaltyRow(icon: "wineglass", violation: "Nồng độ cồn (cao nhất)", penalty: "30–40 triệu + trừ 12 điểm")
                            Divider().padding(.horizontal, 16)
                            PenaltyRow(icon: "gauge.with.dots.needle.100percent", violation: "Quá tốc độ > 35 km/h", penalty: "12–14 triệu + trừ 10 điểm")
                            Divider().padding(.horizontal, 16)
                            PenaltyRow(icon: "doc.text", violation: "Không có GPLX", penalty: "18–20 triệu")
                            Divider().padding(.horizontal, 16)
                            PenaltyRow(icon: "arrow.uturn.left", violation: "Ngược chiều cao tốc", penalty: "40–50 triệu + trừ 12 điểm")
                        }
                        .glassCard()
                    }
            }
            .padding(.horizontal, 20)
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

private struct RefSection<Content: View>: View {
    let title: String
    let icon: String
    var accentColor: Color = .appPrimary
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(accentColor)
                Text(title)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)
            }

            VStack(spacing: 0) {
                content()
            }
            .glassCard()
        }
    }
}

// MARK: - Ref Row (key-value inside a section)

private struct RefRow: View {
    let label: String
    let value: String
    let unit: String
    var accentColor: Color = .appPrimary

    init(_ label: String, value: String, unit: String, accentColor: Color = .appPrimary) {
        self.label = label
        self.value = value
        self.unit = unit
        self.accentColor = accentColor
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextDark)
            Spacer()
            HStack(spacing: 3) {
                Text(value)
                    .font(.system(size: 15, weight: .bold).monospacedDigit())
                    .foregroundStyle(accentColor)
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
}

// MARK: - Rule Card

private struct RuleCard: View {
    let icon: String
    let title: String
    let detail: String
    var accentColor: Color = .appPrimary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(accentColor)
                .frame(width: 28, height: 28)
                .background(accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextMedium)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCard()
    }
}

// MARK: - Penalty Row

private struct PenaltyRow: View {
    let icon: String
    let violation: String
    let penalty: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(violation)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextDark)
                Text(penalty)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
}
