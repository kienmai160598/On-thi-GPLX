import SwiftUI

struct SpeedDistanceReferenceView: View {
    @State private var selectedSection: SpeedSection? = nil

    private var filterIcon: String {
        selectedSection != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }

    private enum SpeedSection: String, CaseIterable, Identifiable {
        case speed = "Tốc độ"
        case distance = "Khoảng cách"
        case alcohol = "Nồng độ cồn"
        case rules = "Quy tắc"
        case penalty = "Mức phạt"

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if selectedSection == nil || selectedSection == .speed {
                    // MARK: - Speed limits in urban areas
                    SectionTitle(title: "Tốc độ trong đô thị")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        SpeedRow(vehicle: "Ô tô con, xe máy", speed: "60 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô tải (trên 3.5T)", speed: "50 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô kéo moóc, xe buýt", speed: "40 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô chở học sinh", speed: "40 km/h")
                    }
                    .glassCard()
                    .padding(.bottom, 20)

                    // MARK: - Speed limits outside urban areas
                    SectionTitle(title: "Tốc độ ngoài đô thị (đường 2 chiều)")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        SpeedRow(vehicle: "Ô tô con, xe máy", speed: "80 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô tải (trên 3.5T)", speed: "70 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô kéo moóc, xe buýt", speed: "60 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô chở học sinh", speed: "60 km/h")
                    }
                    .glassCard()
                    .padding(.bottom, 20)

                    // MARK: - Speed limits outside urban (one-way/divided)
                    SectionTitle(title: "Tốc độ ngoài đô thị (đường 1 chiều / có dải phân cách)")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        SpeedRow(vehicle: "Ô tô con", speed: "90 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Xe máy", speed: "70 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô tải (trên 3.5T)", speed: "80 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Ô tô kéo moóc, xe buýt", speed: "70 km/h")
                    }
                    .glassCard()
                    .padding(.bottom, 20)

                    // MARK: - Expressway
                    SectionTitle(title: "Tốc độ trên cao tốc")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        SpeedRow(vehicle: "Tối đa (theo biển)", speed: "120 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Tối thiểu", speed: "60 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Làn trái (nhanh nhất)", speed: "100-120 km/h")
                        Divider().padding(.horizontal, 16)
                        SpeedRow(vehicle: "Làn phải (chậm nhất)", speed: "60-80 km/h")
                    }
                    .glassCard()
                    .padding(.bottom, 20)
                }

                if selectedSection == nil || selectedSection == .distance {
                    // MARK: - Safe following distance
                    SectionTitle(title: "Khoảng cách an toàn")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        DistanceRow(speed: "60 km/h", distance: "35 m")
                        Divider().padding(.horizontal, 16)
                        DistanceRow(speed: "60-80 km/h", distance: "55 m")
                        Divider().padding(.horizontal, 16)
                        DistanceRow(speed: "80-100 km/h", distance: "70 m")
                        Divider().padding(.horizontal, 16)
                        DistanceRow(speed: "100-120 km/h", distance: "100 m")
                    }
                    .glassCard()
                    .padding(.bottom, 20)
                }

                if selectedSection == nil || selectedSection == .alcohol {
                    // MARK: - Alcohol limits
                    SectionTitle(title: "Nồng độ cồn")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        RuleRow(text: "Xe ô tô: 0 mg/lít khí thở", textColor: .appError)
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Xe máy: 0 mg/lít khí thở", textColor: .appError)
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Nghiêm cấm điều khiển xe khi có nồng độ cồn", textColor: .appWarning)
                    }
                    .glassCard()
                    .padding(.bottom, 20)
                }

                if selectedSection == nil || selectedSection == .rules {
                    // MARK: - Key rules
                    SectionTitle(title: "Quy tắc quan trọng")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        RuleRow(text: "Thứ tự ưu tiên: Xe ưu tiên > Biển báo > Đèn tín hiệu > Vạch kẻ đường > Quy tắc chung")
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Ngã tư không đèn: Nhường bên phải. Đường ưu tiên > Đường nhánh")
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Vượt xe: Chỉ vượt bên trái, trừ khi xe phía trước rẽ trái")
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Xe ưu tiên: Cứu hoả, cứu thương, công an, quân sự (có còi + đèn)")
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Ban đêm: Dùng đèn chiếu gần trong đô thị, chuyển đèn chiếu gần khi có xe ngược chiều")
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Đỗ xe: Cách ngã ba/tư 5m, cách trạm xe buýt 20m, cách cầu 50m")
                        Divider().padding(.horizontal, 16)
                        RuleRow(text: "Cấm sử dụng điện thoại khi lái xe (kể cả tai nghe)", textColor: .appError)
                    }
                    .glassCard()
                    .padding(.bottom, 20)
                }

                if selectedSection == nil || selectedSection == .penalty {
                    // MARK: - Penalty highlights
                    SectionTitle(title: "Mức phạt nổi bật")
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        PenaltyRow(violation: "Vượt đèn đỏ", penalty: "4-6 triệu (ô tô)")
                        Divider().padding(.horizontal, 16)
                        PenaltyRow(violation: "Nồng độ cồn", penalty: "30-40 triệu + tước GPLX 22-24 tháng")
                        Divider().padding(.horizontal, 16)
                        PenaltyRow(violation: "Chạy quá tốc độ >35km/h", penalty: "12-20 triệu + tước GPLX")
                        Divider().padding(.horizontal, 16)
                        PenaltyRow(violation: "Không có GPLX", penalty: "10-14 triệu")
                        Divider().padding(.horizontal, 16)
                        PenaltyRow(violation: "Đi ngược chiều cao tốc", penalty: "16-18 triệu + tước GPLX")
                    }
                    .glassCard()
                    .padding(.bottom, 20)
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
                        selectedSection = nil
                    } label: {
                        if selectedSection == nil {
                            Label("Tất cả", systemImage: "checkmark")
                        } else {
                            Text("Tất cả")
                        }
                    }

                    ForEach(SpeedSection.allCases) { section in
                        Button {
                            selectedSection = section
                        } label: {
                            if selectedSection == section {
                                Label(section.rawValue, systemImage: "checkmark")
                            } else {
                                Text(section.rawValue)
                            }
                        }
                    }
                } label: {
                    Image(systemName: filterIcon)
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }
}

// MARK: - Speed Row

private struct SpeedRow: View {
    let vehicle: String
    let speed: String

    var body: some View {
        HStack {
            Text(vehicle)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextDark)
            Spacer()
            Text(speed)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.appPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
}

// MARK: - Distance Row

private struct DistanceRow: View {
    let speed: String
    let distance: String

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "speedometer")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextLight)
                Text(speed)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextDark)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "arrow.left.and.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextLight)
                Text("\u{2265} \(distance)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.appWarning)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
}

// MARK: - Rule Row

private struct RuleRow: View {
    let text: String
    var textColor: Color = .appTextDark

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(textColor)
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
    }
}

// MARK: - Penalty Row

private struct PenaltyRow: View {
    let violation: String
    let penalty: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(violation)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
            Text(penalty)
                .font(.system(size: 12))
                .foregroundStyle(Color.appError)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
}
