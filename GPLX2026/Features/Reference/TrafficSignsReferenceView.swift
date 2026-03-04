import SwiftUI

struct TrafficSignsReferenceView: View {
    @State private var selectedCategory: String? = nil

    private var displayCategories: [SignCategory] {
        if let selected = selectedCategory {
            return SignCategory.all.filter { $0.name == selected }
        }
        return SignCategory.all
    }

    private var filterIcon: String {
        selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(displayCategories.enumerated()), id: \.element.id) { i, category in
                    SectionTitle(title: category.name)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        ForEach(Array(category.signs.enumerated()), id: \.element.id) { j, sign in
                            if j > 0 {
                                Divider().padding(.horizontal, 16)
                            }
                            SignRow(sign: sign)
                        }
                    }
                    .glassCard()
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .screenHeader("Biển báo giao thông")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        selectedCategory = nil
                    } label: {
                        if selectedCategory == nil {
                            Label("Tất cả", systemImage: "checkmark")
                        } else {
                            Text("Tất cả")
                        }
                    }

                    ForEach(SignCategory.all) { category in
                        Button {
                            selectedCategory = category.name
                        } label: {
                            if selectedCategory == category.name {
                                Label("\(category.name) (\(category.signs.count))", systemImage: "checkmark")
                            } else {
                                Text("\(category.name) (\(category.signs.count))")
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

// MARK: - Sign Row

private struct SignRow: View {
    let sign: TrafficSign

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: sign.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.appDivider)
                            .frame(width: 44, height: 44)
                        Image(systemName: sign.fallbackIcon)
                            .font(.system(size: 18))
                            .foregroundStyle(Color.appTextLight)
                    }
                default:
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appDivider.opacity(0.5))
                        .frame(width: 44, height: 44)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(sign.code)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.appTextLight)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.appDivider)
                        .clipShape(RoundedRectangle(cornerRadius: 3))

                    Text(sign.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appTextDark)
                }

                Text(sign.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMedium)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Data

private struct TrafficSign: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let description: String
    let imageCode: String
    let fallbackIcon: String

    var imageURL: URL? {
        URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/Vietnam_road_sign_\(imageCode).svg?width=200")
    }
}

private struct SignCategory: Identifiable {
    let id = UUID()
    let name: String
    let signs: [TrafficSign]

    static let all: [SignCategory] = [
        SignCategory(name: "Biển cấm", signs: [
            TrafficSign(code: "P.101", name: "Đường cấm", description: "Cấm tất cả phương tiện và người đi bộ", imageCode: "P101", fallbackIcon: "nosign"),
            TrafficSign(code: "P.102", name: "Cấm đi ngược chiều", description: "Cấm tất cả phương tiện đi vào theo chiều đặt biển", imageCode: "P102", fallbackIcon: "minus"),
            TrafficSign(code: "P.103a", name: "Cấm ô tô", description: "Cấm ô tô đi vào, trừ xe ưu tiên theo quy định", imageCode: "P103a", fallbackIcon: "car.fill"),
            TrafficSign(code: "P.103b", name: "Cấm ô tô rẽ trái", description: "Cấm ô tô rẽ trái", imageCode: "P103b", fallbackIcon: "car.fill"),
            TrafficSign(code: "P.104", name: "Cấm mô tô", description: "Cấm mô tô và xe gắn máy đi vào", imageCode: "P104", fallbackIcon: "bicycle"),
            TrafficSign(code: "P.106a", name: "Cấm xe tải", description: "Cấm xe ô tô tải đi vào", imageCode: "P106a", fallbackIcon: "truck.box.fill"),
            TrafficSign(code: "P.107", name: "Cấm xe khách", description: "Cấm xe ô tô khách đi vào", imageCode: "P107", fallbackIcon: "bus.fill"),
            TrafficSign(code: "P.124a", name: "Cấm rẽ trái", description: "Cấm rẽ trái tại nơi đặt biển", imageCode: "P124a", fallbackIcon: "arrow.turn.up.left"),
            TrafficSign(code: "P.124b", name: "Cấm rẽ phải", description: "Cấm rẽ phải tại nơi đặt biển", imageCode: "P124b", fallbackIcon: "arrow.turn.up.right"),
            TrafficSign(code: "P.124c", name: "Cấm quay đầu", description: "Cấm quay đầu xe tại nơi đặt biển", imageCode: "P124c", fallbackIcon: "arrow.uturn.left"),
            TrafficSign(code: "P.125", name: "Cấm vượt", description: "Cấm mọi loại xe vượt nhau", imageCode: "P125", fallbackIcon: "arrow.left.arrow.right"),
            TrafficSign(code: "P.130", name: "Cấm dừng và đỗ xe", description: "Cấm dừng xe và đỗ xe ở lòng đường và lề đường", imageCode: "P130", fallbackIcon: "xmark"),
            TrafficSign(code: "P.131a", name: "Cấm đỗ xe", description: "Cấm đỗ xe ở lòng đường và hè phố", imageCode: "P131a", fallbackIcon: "nosign"),
            TrafficSign(code: "P.127", name: "Cấm còi", description: "Cấm sử dụng còi trong khu vực đặt biển", imageCode: "P127", fallbackIcon: "speaker.slash.fill"),
        ]),
        SignCategory(name: "Biển nguy hiểm & cảnh báo", signs: [
            TrafficSign(code: "W.201a", name: "Chỗ ngoặt nguy hiểm trái", description: "Báo trước đoạn đường nguy hiểm có chỗ ngoặt sang trái", imageCode: "W201a", fallbackIcon: "arrow.turn.up.left"),
            TrafficSign(code: "W.201b", name: "Chỗ ngoặt nguy hiểm phải", description: "Báo trước đoạn đường nguy hiểm có chỗ ngoặt sang phải", imageCode: "W201b", fallbackIcon: "arrow.turn.up.right"),
            TrafficSign(code: "W.202a", name: "Nhiều chỗ ngoặt liên tiếp", description: "Báo trước đoạn đường có nhiều chỗ ngoặt liên tiếp", imageCode: "W202a", fallbackIcon: "arrow.triangle.swap"),
            TrafficSign(code: "W.205a", name: "Đường giao nhau", description: "Báo trước nơi giao nhau cùng cấp, mức ưu tiên như nhau", imageCode: "W205a", fallbackIcon: "plus"),
            TrafficSign(code: "W.205b", name: "Giao nhau hình chữ T", description: "Báo trước nơi giao nhau cùng cấp theo hình chữ T", imageCode: "W205b", fallbackIcon: "arrow.up.arrow.down"),
            TrafficSign(code: "W.207a", name: "Giao nhau với đường sắt có rào", description: "Báo trước chỗ giao nhau với đường sắt có rào chắn", imageCode: "W207a", fallbackIcon: "tram.fill"),
            TrafficSign(code: "W.208", name: "Giao nhau với đường sắt không rào", description: "Báo trước chỗ giao nhau với đường sắt không có rào chắn", imageCode: "W208", fallbackIcon: "tram.fill"),
            TrafficSign(code: "W.209", name: "Nơi có người đi bộ", description: "Báo trước sắp đến đoạn đường có người đi bộ cắt ngang", imageCode: "W209", fallbackIcon: "figure.walk"),
            TrafficSign(code: "W.210", name: "Nơi trẻ em qua đường", description: "Báo trước gần trường học, khu vực trẻ em qua đường", imageCode: "W210", fallbackIcon: "figure.2.and.child.holdinghands"),
            TrafficSign(code: "W.221a", name: "Đường trơn", description: "Báo trước đoạn đường trơn trượt khi trời mưa", imageCode: "W221a", fallbackIcon: "water.waves"),
            TrafficSign(code: "W.224", name: "Đường hẹp", description: "Báo trước đoạn đường bị hẹp lại cả hai bên", imageCode: "W224", fallbackIcon: "arrow.right.and.line.vertical.and.arrow.left"),
            TrafficSign(code: "W.227", name: "Dốc xuống nguy hiểm", description: "Báo trước sắp đến đoạn đường dốc xuống nguy hiểm", imageCode: "W227", fallbackIcon: "arrow.down.right"),
            TrafficSign(code: "W.228", name: "Dốc lên nguy hiểm", description: "Báo trước sắp đến đoạn đường dốc lên nguy hiểm", imageCode: "W228", fallbackIcon: "arrow.up.right"),
            TrafficSign(code: "W.233", name: "Công trường", description: "Báo trước phía trước đang thi công, sửa đường", imageCode: "W233", fallbackIcon: "exclamationmark.triangle.fill"),
        ]),
        SignCategory(name: "Biển hiệu lệnh", signs: [
            TrafficSign(code: "R.301a", name: "Đi thẳng", description: "Các xe chỉ được đi thẳng theo chiều mũi tên", imageCode: "R301a", fallbackIcon: "arrow.up"),
            TrafficSign(code: "R.301b", name: "Rẽ phải", description: "Các xe chỉ được rẽ phải theo chiều mũi tên", imageCode: "R301b", fallbackIcon: "arrow.turn.up.right"),
            TrafficSign(code: "R.301d", name: "Rẽ trái", description: "Các xe chỉ được rẽ trái theo chiều mũi tên", imageCode: "R301d", fallbackIcon: "arrow.turn.up.left"),
            TrafficSign(code: "R.301e", name: "Đi thẳng hoặc rẽ phải", description: "Các xe chỉ được đi thẳng hoặc rẽ phải", imageCode: "R301e", fallbackIcon: "arrow.up.right"),
            TrafficSign(code: "R.303", name: "Nơi giao nhau chạy vòng", description: "Các xe phải chạy vòng theo chiều mũi tên", imageCode: "R303", fallbackIcon: "arrow.triangle.2.circlepath"),
            TrafficSign(code: "R.304", name: "Đường dành cho xe thô sơ", description: "Đường chỉ dành cho xe thô sơ và người đi bộ", imageCode: "R304", fallbackIcon: "figure.walk"),
            TrafficSign(code: "R.305", name: "Tốc độ tối thiểu", description: "Tốc độ tối thiểu cho phép, xe không được chạy chậm hơn", imageCode: "R305", fallbackIcon: "speedometer"),
        ]),
        SignCategory(name: "Biển chỉ dẫn", signs: [
            TrafficSign(code: "I.407a", name: "Đường một chiều", description: "Đường chỉ cho phép đi theo một chiều", imageCode: "I407a", fallbackIcon: "arrow.right"),
            TrafficSign(code: "I.408", name: "Đường cho ô tô", description: "Đường dành riêng cho ô tô, không cho phương tiện khác", imageCode: "I408", fallbackIcon: "car.fill"),
            TrafficSign(code: "I.409", name: "Nơi đỗ xe", description: "Chỉ dẫn nơi được phép đỗ xe", imageCode: "I409", fallbackIcon: "p.square.fill"),
            TrafficSign(code: "I.423", name: "Trạm xăng", description: "Chỉ dẫn phía trước có trạm xăng, dầu", imageCode: "I423", fallbackIcon: "fuelpump.fill"),
            TrafficSign(code: "I.425", name: "Bệnh viện", description: "Chỉ dẫn phía trước có bệnh viện hoặc cơ sở y tế", imageCode: "I425", fallbackIcon: "cross.fill"),
            TrafficSign(code: "I.434a", name: "Nơi quay đầu", description: "Chỉ dẫn nơi cho phép quay đầu xe", imageCode: "I434a", fallbackIcon: "arrow.uturn.left"),
        ]),
        SignCategory(name: "Biển phụ & vạch kẻ đường", signs: [
            TrafficSign(code: "S.501", name: "Phạm vi tác dụng", description: "Biển phụ cho biết chiều dài đoạn đường biển chính có hiệu lực", imageCode: "S501", fallbackIcon: "ruler"),
            TrafficSign(code: "S.502a", name: "Khoảng cách", description: "Biển phụ cho biết khoảng cách từ biển đến nơi cần báo", imageCode: "S502a", fallbackIcon: "arrow.left.and.right"),
            TrafficSign(code: "--", name: "Vạch liền", description: "Không được lấn làn, không được đè lên vạch", imageCode: "", fallbackIcon: "minus"),
            TrafficSign(code: "--", name: "Vạch đứt", description: "Được phép chuyển làn khi an toàn", imageCode: "", fallbackIcon: "line.3.horizontal"),
            TrafficSign(code: "--", name: "Vạch dừng xe", description: "Xe phải dừng trước vạch khi có tín hiệu đèn đỏ", imageCode: "", fallbackIcon: "stop.fill"),
        ]),
    ]
}
