import SwiftUI

struct TrafficSignsReferenceView: View {
    @State private var selectedCategory: String? = nil
    @State private var searchText = ""

    private var displayCategories: [SignCategory] {
        if let selected = selectedCategory {
            return SignCategory.all.filter { $0.name == selected }
        }
        return SignCategory.all
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(displayCategories.enumerated()), id: \.element.id) { i, category in
                    let signs = filteredSigns(category.signs)
                    if !signs.isEmpty {
                        SectionTitle(title: category.name)
                            .padding(.bottom, 10)

                        VStack(spacing: 0) {
                            ForEach(Array(signs.enumerated()), id: \.element.id) { j, sign in
                                if j > 0 {
                                    Divider().padding(.horizontal, 16)
                                }
                                SignRow(sign: sign)
                            }
                        }
                        .glassCard()
                        .padding(.bottom, 24)
                    }
                }
            }
            .padding(.horizontal, 20)
            .iPadReadable(maxWidth: 900)
            .padding(.bottom, 20)
        }
        .searchable(text: $searchText, prompt: "Tìm biển báo...")
        .screenHeader("Biển báo giao thông")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        withAnimation { selectedCategory = nil }
                    } label: {
                        Label("Tất cả", systemImage: selectedCategory == nil ? "checkmark" : "")
                    }
                    ForEach(SignCategory.all) { category in
                        Button {
                            withAnimation { selectedCategory = category.name }
                        } label: {
                            Label(
                                "\(category.name) (\(category.signs.count))",
                                systemImage: selectedCategory == category.name ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    Image(systemName: selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private func filteredSigns(_ signs: [TrafficSign]) -> [TrafficSign] {
        guard !searchText.isEmpty else { return signs }
        return signs.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}


// MARK: - Sign Row

private struct SignRow: View {
    let sign: TrafficSign

    var body: some View {
        HStack(spacing: 14) {
            if let path = Bundle.main.path(forResource: sign.imageName, ofType: "png"),
               let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appDivider)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.appSans(size: 16))
                            .foregroundStyle(Color.appTextLight)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(sign.code)
                        .font(.appSans(size: 11))
                        .foregroundStyle(sign.codeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(sign.codeBgColor)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Text(sign.name)
                        .font(.appSans(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)
                }

                Text(sign.description)
                    .font(.appSans(size: 13))
                    .foregroundStyle(Color.appTextMedium)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Data

private struct TrafficSign: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let description: String
    let category: SignType

    enum SignType {
        case prohibition  // Biển cấm
        case warning      // Biển nguy hiểm
        case mandatory    // Biển hiệu lệnh
        case guide        // Biển chỉ dẫn
        case supplement   // Biển phụ
    }

    /// Image file name: "P.101" → "P101"
    var imageName: String {
        code.replacingOccurrences(of: ".", with: "")
    }

    var codeColor: Color {
        switch category {
        case .prohibition: .red
        case .warning: .orange
        case .mandatory: .blue
        case .guide: Color(hex: 0x2E7D32)
        case .supplement: Color.appTextLight
        }
    }

    var codeBgColor: Color {
        switch category {
        case .prohibition: Color.red.opacity(0.08)
        case .warning: Color.orange.opacity(0.08)
        case .mandatory: Color.blue.opacity(0.08)
        case .guide: Color.green.opacity(0.08)
        case .supplement: Color.appDivider
        }
    }
}

private struct SignCategory: Identifiable {
    let id = UUID()
    let name: String
    let signs: [TrafficSign]

    // MARK: - QCVN 41:2019/BGTVT - Biển báo giao thông đường bộ Việt Nam

    static let all: [SignCategory] = [
        SignCategory(name: "Biển cấm", signs: [
            TrafficSign(code: "P.101", name: "Đường cấm", description: "Cấm tất cả phương tiện và người đi bộ đi lại cả hai hướng", category: .prohibition),
            TrafficSign(code: "P.102", name: "Cấm đi ngược chiều", description: "Cấm tất cả phương tiện đi vào theo chiều đặt biển", category: .prohibition),
            TrafficSign(code: "P.103a", name: "Cấm xe ô tô", description: "Cấm xe ô tô đi vào (trừ xe ưu tiên theo quy định)", category: .prohibition),
            TrafficSign(code: "P.103b", name: "Cấm ô tô và mô tô", description: "Cấm xe ô tô và xe mô tô đi vào", category: .prohibition),
            TrafficSign(code: "P.104", name: "Cấm xe mô tô", description: "Cấm xe mô tô hai bánh và xe gắn máy đi vào", category: .prohibition),
            TrafficSign(code: "P.106a", name: "Cấm xe tải", description: "Cấm xe ô tô tải đi vào (không hạn chế tải trọng)", category: .prohibition),
            TrafficSign(code: "P.106b", name: "Cấm xe tải trên N tấn", description: "Cấm xe tải có tải trọng vượt quá trị số ghi trên biển", category: .prohibition),
            TrafficSign(code: "P.107", name: "Cấm xe khách", description: "Cấm xe ô tô khách và xe buýt đi vào", category: .prohibition),
            TrafficSign(code: "P.112", name: "Cấm người đi bộ", description: "Cấm người đi bộ qua lại trên đoạn đường đặt biển", category: .prohibition),
            TrafficSign(code: "P.115", name: "Hạn chế trọng lượng", description: "Cấm xe có tổng trọng lượng vượt quá trị số (tấn) ghi trên biển", category: .prohibition),
            TrafficSign(code: "P.117", name: "Hạn chế chiều cao", description: "Cấm xe có chiều cao toàn bộ vượt quá trị số (m) trên biển", category: .prohibition),
            TrafficSign(code: "P.124a", name: "Cấm rẽ trái", description: "Cấm các loại xe rẽ trái tại nơi đặt biển", category: .prohibition),
            TrafficSign(code: "P.124b", name: "Cấm rẽ phải", description: "Cấm các loại xe rẽ phải tại nơi đặt biển", category: .prohibition),
            TrafficSign(code: "P.124c", name: "Cấm quay đầu xe", description: "Cấm các loại xe quay đầu tại nơi đặt biển", category: .prohibition),
            TrafficSign(code: "P.125", name: "Cấm vượt", description: "Cấm mọi loại xe cơ giới vượt nhau trên đoạn đường đặt biển", category: .prohibition),
            TrafficSign(code: "P.127", name: "Cấm sử dụng còi", description: "Cấm sử dụng còi trong khu vực đặt biển (bệnh viện, trường học...)", category: .prohibition),
            TrafficSign(code: "P.128", name: "Tốc độ tối đa", description: "Cấm xe chạy quá tốc độ ghi trên biển (km/h)", category: .prohibition),
            TrafficSign(code: "P.130", name: "Cấm dừng và đỗ xe", description: "Cấm dừng xe và đỗ xe ở lòng đường và lề đường bên đặt biển", category: .prohibition),
            TrafficSign(code: "P.131a", name: "Cấm đỗ xe", description: "Cấm đỗ xe ở lòng đường và lề đường bên đặt biển (được dừng xe)", category: .prohibition),
            TrafficSign(code: "P.137", name: "Cấm rẽ trái và quay đầu", description: "Cấm rẽ trái và cấm quay đầu xe tại nơi đặt biển", category: .prohibition),
        ]),
        SignCategory(name: "Biển nguy hiểm & cảnh báo", signs: [
            TrafficSign(code: "W.201a", name: "Ngoặt nguy hiểm bên trái", description: "Báo trước sắp đến chỗ ngoặt nguy hiểm phía bên trái", category: .warning),
            TrafficSign(code: "W.201b", name: "Ngoặt nguy hiểm bên phải", description: "Báo trước sắp đến chỗ ngoặt nguy hiểm phía bên phải", category: .warning),
            TrafficSign(code: "W.202a", name: "Nhiều chỗ ngoặt liên tiếp", description: "Báo trước đoạn đường có nhiều chỗ ngoặt nguy hiểm liên tiếp", category: .warning),
            TrafficSign(code: "W.205a", name: "Đường giao nhau", description: "Báo trước nơi đường giao nhau cùng cấp (các hướng có quyền ưu tiên như nhau)", category: .warning),
            TrafficSign(code: "W.205b", name: "Giao nhau hình chữ T", description: "Báo trước nơi giao nhau có dạng hình chữ T", category: .warning),
            TrafficSign(code: "W.205d", name: "Giao nhau hình chữ Y", description: "Báo trước nơi giao nhau có dạng hình chữ Y", category: .warning),
            TrafficSign(code: "W.207a", name: "Giao đường sắt có rào chắn", description: "Báo trước nơi giao nhau giữa đường bộ và đường sắt có rào chắn", category: .warning),
            TrafficSign(code: "W.208", name: "Giao đường sắt không rào chắn", description: "Báo trước nơi giao nhau giữa đường bộ và đường sắt không có rào chắn", category: .warning),
            TrafficSign(code: "W.209", name: "Nơi người đi bộ cắt ngang", description: "Báo trước sắp đến đoạn đường thường có người đi bộ cắt ngang", category: .warning),
            TrafficSign(code: "W.210", name: "Nơi trẻ em qua đường", description: "Báo trước gần trường học, khu vui chơi, nơi trẻ em thường qua đường", category: .warning),
            TrafficSign(code: "W.211", name: "Đường lồi lõm", description: "Báo trước đoạn đường có mặt đường bị lồi lõm, gồ ghề", category: .warning),
            TrafficSign(code: "W.221a", name: "Đường trơn trượt", description: "Báo trước đoạn đường trơn trượt do mặt đường ướt hoặc bẩn", category: .warning),
            TrafficSign(code: "W.224", name: "Đường hẹp cả hai bên", description: "Báo trước đoạn đường bị thu hẹp lại từ cả hai phía", category: .warning),
            TrafficSign(code: "W.225", name: "Đường hẹp một bên", description: "Báo trước đoạn đường bị thu hẹp về một phía (trái hoặc phải)", category: .warning),
            TrafficSign(code: "W.226", name: "Đường lên dốc", description: "Báo trước đoạn đường lên dốc nguy hiểm (số trên biển là độ dốc %)", category: .warning),
            TrafficSign(code: "W.227", name: "Đường xuống dốc", description: "Báo trước đoạn đường xuống dốc nguy hiểm (số trên biển là độ dốc %)", category: .warning),
            TrafficSign(code: "W.228", name: "Đường có đá lở", description: "Báo trước đoạn đường có nguy cơ đá rơi, đá lở từ vách núi", category: .warning),
            TrafficSign(code: "W.233", name: "Công trường", description: "Báo trước đang thi công, sửa chữa đường, chú ý giảm tốc độ", category: .warning),
            TrafficSign(code: "W.245", name: "Đường đôi", description: "Báo trước sắp đến đoạn đường đôi có dải phân cách giữa", category: .warning),
            TrafficSign(code: "W.246a", name: "Hết đường đôi", description: "Báo trước hết đoạn đường đôi, nhập lại thành đường hai chiều", category: .warning),
        ]),
        SignCategory(name: "Biển hiệu lệnh", signs: [
            TrafficSign(code: "R.301a", name: "Đi thẳng", description: "Bắt buộc phải đi thẳng theo hướng mũi tên (không được rẽ)", category: .mandatory),
            TrafficSign(code: "R.301b", name: "Rẽ phải", description: "Bắt buộc phải rẽ phải theo hướng mũi tên", category: .mandatory),
            TrafficSign(code: "R.301c", name: "Rẽ trái", description: "Bắt buộc phải rẽ trái theo hướng mũi tên", category: .mandatory),
            TrafficSign(code: "R.301d", name: "Đi thẳng hoặc rẽ phải", description: "Bắt buộc phải đi thẳng hoặc rẽ phải", category: .mandatory),
            TrafficSign(code: "R.301e", name: "Đi thẳng hoặc rẽ trái", description: "Bắt buộc phải đi thẳng hoặc rẽ trái", category: .mandatory),
            TrafficSign(code: "R.303", name: "Nơi giao nhau chạy vòng", description: "Bắt buộc phải chạy vòng theo hướng mũi tên (ngược chiều kim đồng hồ)", category: .mandatory),
            TrafficSign(code: "R.304", name: "Đường dành cho xe thô sơ", description: "Đường chỉ dành cho xe thô sơ và người đi bộ", category: .mandatory),
            TrafficSign(code: "R.305", name: "Tốc độ tối thiểu", description: "Bắt buộc chạy tốc độ tối thiểu ghi trên biển (km/h), không được chậm hơn", category: .mandatory),
            TrafficSign(code: "R.407", name: "Đường người đi bộ cắt ngang", description: "Bắt buộc cho người đi bộ qua đường tại vạch kẻ đường", category: .mandatory),
        ]),
        SignCategory(name: "Biển chỉ dẫn", signs: [
            TrafficSign(code: "I.401", name: "Bắt đầu đường ưu tiên", description: "Báo hiệu bắt đầu đường ưu tiên, xe trên đường này được đi trước", category: .guide),
            TrafficSign(code: "I.402", name: "Hết đường ưu tiên", description: "Báo hiệu hết đoạn đường ưu tiên", category: .guide),
            TrafficSign(code: "I.403", name: "Đường dành cho ô tô", description: "Báo hiệu đoạn đường dành riêng cho ô tô chạy với tốc độ cao", category: .guide),
            TrafficSign(code: "I.407a", name: "Đường một chiều", description: "Đường chỉ cho phép đi theo một chiều (hướng mũi tên)", category: .guide),
            TrafficSign(code: "I.408", name: "Đường cho ô tô", description: "Đường dành riêng cho xe ô tô, cấm phương tiện khác", category: .guide),
            TrafficSign(code: "I.409", name: "Nơi đỗ xe", description: "Chỉ dẫn nơi được phép đỗ xe", category: .guide),
            TrafficSign(code: "I.422", name: "Bến xe buýt", description: "Chỉ dẫn vị trí bến xe buýt, điểm đón trả khách", category: .guide),
            TrafficSign(code: "I.423", name: "Trạm xăng dầu", description: "Chỉ dẫn phía trước có trạm xăng, dầu", category: .guide),
            TrafficSign(code: "I.425", name: "Bệnh viện", description: "Chỉ dẫn phía trước có bệnh viện hoặc cơ sở y tế", category: .guide),
            TrafficSign(code: "I.434a", name: "Nơi quay đầu xe", description: "Chỉ dẫn nơi cho phép quay đầu xe", category: .guide),
            TrafficSign(code: "I.435", name: "Đường cụt", description: "Báo hiệu phía trước là đường cụt, không có lối thoát", category: .guide),
        ]),
        SignCategory(name: "Biển phụ", signs: [
            TrafficSign(code: "S.501", name: "Phạm vi tác dụng", description: "Cho biết chiều dài đoạn đường mà biển chính phía trên có hiệu lực", category: .supplement),
            TrafficSign(code: "S.502a", name: "Khoảng cách đến đối tượng", description: "Cho biết khoảng cách từ vị trí đặt biển đến nơi cần báo hiệu", category: .supplement),
            TrafficSign(code: "S.503a", name: "Hướng tác dụng", description: "Cho biết hướng tác dụng của biển chính (theo mũi tên)", category: .supplement),
        ]),
    ]
}
