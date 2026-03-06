import Foundation

// MARK: - HazardSituation

struct HazardSituation: Codable, Identifiable {
    let id: Int
    let title: String
    let chapter: Int
    let perfectStart: Double
    let perfectEnd: Double
    let tip: String

    var videoFileName: String {
        String(format: "th%03d", id)
    }

    var videoURL: URL {
        // Safe: format is always valid ASCII URL
        guard let url = URL(string: "https://gmec.vn/videos/\(videoFileName).mp4") else {
            fatalError("Invalid video URL for situation \(id)")
        }
        return url
    }

    /// Score based on tap time. Linear interpolation: perfectStart = 5, perfectEnd = 0.
    func score(tapTime: Double?) -> Int {
        guard let tapTime, tapTime >= perfectStart, tapTime <= perfectEnd else { return 0 }
        let range = perfectEnd - perfectStart
        guard range > 0 else { return 5 }
        let fraction = (tapTime - perfectStart) / range
        return max(0, Int(round(5.0 * (1.0 - fraction))))
    }
}

// MARK: - Chapter Info

extension HazardSituation {
    struct Chapter {
        let id: Int
        let name: String
        let range: ClosedRange<Int>
    }

    static let chapters: [Chapter] = [
        Chapter(id: 1, name: "Trong khu vực đô thị", range: 1...29),
        Chapter(id: 2, name: "Đường ngoài đô thị", range: 30...43),
        Chapter(id: 3, name: "Đường cao tốc", range: 44...63),
        Chapter(id: 4, name: "Đường đèo núi", range: 64...73),
        Chapter(id: 5, name: "Đường quốc lộ, tỉnh lộ", range: 74...90),
        Chapter(id: 6, name: "Tình huống tai nạn thực tế", range: 91...120),
    ]

    var chapterName: String {
        Self.chapters.first(where: { $0.range.contains(id) })?.name ?? ""
    }
}

// MARK: - All 120 Situations

extension HazardSituation {
    // swiftlint:disable function_body_length
    static let all: [HazardSituation] = [
        // Chapter 1: Trong khu vực đô thị (1-29)
        HazardSituation(id: 1, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.427, perfectEnd: 13.140,
                         tip: "Chú ý người đi bộ sang đường bất ngờ tại khu vực đông đúc."),
        HazardSituation(id: 2, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 17.915, perfectEnd: 20.133,
                         tip: "Xe máy có thể bất ngờ chuyển làn mà không xi-nhan. Giữ khoảng cách an toàn."),
        HazardSituation(id: 3, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 15.076, perfectEnd: 18.040,
                         tip: "Khi đi gần xe buýt đang dừng, cẩn thận hành khách bước xuống hoặc qua đường."),
        HazardSituation(id: 4, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.527, perfectEnd: 15.289,
                         tip: "Tại ngã tư, luôn quan sát xe từ đường ngang có thể không nhường đường."),
        HazardSituation(id: 5, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 12.397, perfectEnd: 16.473,
                         tip: "Cửa xe đậu ven đường có thể bất ngờ mở ra. Giữ khoảng cách với hàng xe đậu."),
        HazardSituation(id: 6, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 13.171, perfectEnd: 16.443,
                         tip: "Trẻ em chơi gần đường có thể chạy ra bất cứ lúc nào. Giảm tốc khu dân cư."),
        HazardSituation(id: 7, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.536, perfectEnd: 14.986,
                         tip: "Xe tải lớn có điểm mù rộng. Không đi sát và không vượt ở khúc cua."),
        HazardSituation(id: 8, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.506, perfectEnd: 13.450,
                         tip: "Người đi xe đạp có thể đột ngột rẽ trái mà không nhìn sau."),
        HazardSituation(id: 9, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 8.241, perfectEnd: 10.980,
                         tip: "Khi có xe ngược chiều rẽ trái, chú ý xe máy phía sau xe đó có thể bị che khuất."),
        HazardSituation(id: 10, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 11.883, perfectEnd: 16.232,
                         tip: "Đèn tín hiệu chuyển vàng, xe phía trước có thể phanh gấp. Luôn giữ khoảng cách."),
        HazardSituation(id: 11, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Tại vòng xuyến, xe đi trong vòng có quyền ưu tiên. Nhường đường đúng luật."),
        HazardSituation(id: 12, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Xe từ hẻm, ngõ nhỏ ra đường lớn thường không quan sát kỹ. Giảm tốc khi đi qua."),
        HazardSituation(id: 13, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Người đi bộ băng qua đường tại vị trí không có vạch kẻ. Cảnh giác khu mua sắm."),
        HazardSituation(id: 14, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe máy đi ngược chiều trên phố một chiều rất nguy hiểm. Sẵn sàng phanh."),
        HazardSituation(id: 15, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Khi vượt xe đậu ven đường, để ý có bóng người sau xe — có thể họ bước ra."),
        HazardSituation(id: 16, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Gần trường học, trẻ em thường chạy qua đường không quan sát. Giảm tốc dưới 30km/h."),
        HazardSituation(id: 17, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 13.0, perfectEnd: 16.0,
                         tip: "Taxi dừng đột ngột để đón khách. Quan sát hành vi xe taxi phía trước."),
        HazardSituation(id: 18, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe buýt rời bến có thể lấn làn. Nhường đường cho xe buýt khi có tín hiệu."),
        HazardSituation(id: 19, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 11.856, perfectEnd: 14.245,
                         tip: "Khi rẽ phải, chú ý xe máy đi thẳng từ phía sau bên phải — điểm mù nguy hiểm."),
        HazardSituation(id: 20, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 13.200, perfectEnd: 15.722,
                         tip: "Đường ướt sau mưa giảm ma sát. Tăng khoảng cách phanh gấp đôi."),
        HazardSituation(id: 21, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.115, perfectEnd: 12.980,
                         tip: "Xe container rẽ cần bán kính lớn, có thể lấn sang làn bạn. Giữ khoảng cách."),
        HazardSituation(id: 22, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Người già qua đường chậm hơn dự kiến. Kiên nhẫn chờ, không bóp còi."),
        HazardSituation(id: 23, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 12.5, perfectEnd: 15.5,
                         tip: "Giao lộ không đèn tín hiệu: nhường xe bên phải. Quan sát kỹ trước khi đi."),
        HazardSituation(id: 24, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe máy chở hàng cồng kềnh dễ mất thăng bằng. Vượt với khoảng cách rộng."),
        HazardSituation(id: 25, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Khi có xe cứu thương/cứu hỏa, tấp vào lề phải và dừng lại nhường đường."),
        HazardSituation(id: 26, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 9.0, perfectEnd: 12.0,
                         tip: "Chó, mèo chạy ngang đường có thể khiến xe phía trước phanh gấp."),
        HazardSituation(id: 27, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Khi quay đầu xe trong phố, chú ý cả hai hướng giao thông và người đi bộ."),
        HazardSituation(id: 28, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Đường có dải phân cách mềm, xe máy hay lách qua. Cẩn thận khi vượt."),
        HazardSituation(id: 29, title: "Bạn xử lý tình huống này như thế nào?", chapter: 1, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Xe tải dừng bên đường che khuất tầm nhìn. Giảm tốc khi vượt qua xe lớn."),

        // Chapter 2: Đường ngoài đô thị (30-43)
        HazardSituation(id: 30, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Đường ngoài đô thị hay có gia súc băng qua. Chú ý hai bên đường."),
        HazardSituation(id: 31, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Xe máy cày, xe bò đi chậm trên đường lớn. Quan sát kỹ trước khi vượt."),
        HazardSituation(id: 32, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Khúc cua khuất tầm nhìn ngoài đô thị rất nguy hiểm. Giảm tốc và bấm còi."),
        HazardSituation(id: 33, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Xe tải đi chậm trên đường hẹp. Chỉ vượt khi có tầm nhìn xa và đủ chỗ."),
        HazardSituation(id: 34, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Người dân đi bộ ven đường không có vỉa hè. Giữ khoảng cách 1.5m khi vượt."),
        HazardSituation(id: 35, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Đường giao nhau không có biển báo. Giảm tốc và quan sát cả hai hướng."),
        HazardSituation(id: 36, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 9.840, perfectEnd: 12.431,
                         tip: "Xe ngược chiều vượt lấn sang làn bạn. Giảm tốc, tấp vào lề phải."),
        HazardSituation(id: 37, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Đường quê thường có xe đạp đi hàng ngang. Bấm còi từ xa và giảm tốc."),
        HazardSituation(id: 38, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Cầu hẹp chỉ đủ một xe. Kiểm tra biển ưu tiên trước khi qua cầu."),
        HazardSituation(id: 39, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Đường cong liên tục ngoài đô thị. Không vượt xe tại khúc cua."),
        HazardSituation(id: 40, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Sương mù giảm tầm nhìn. Bật đèn sương mù, giảm tốc và giữ khoảng cách."),
        HazardSituation(id: 41, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 13.0, perfectEnd: 16.0,
                         tip: "Ngã ba đường nông thôn thường không có đèn. Giảm tốc và bấm còi cảnh báo."),
        HazardSituation(id: 42, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Đường đất bụi giảm tầm nhìn và ma sát. Giữ khoảng cách an toàn với xe trước."),
        HazardSituation(id: 43, title: "Bạn xử lý tình huống này như thế nào?", chapter: 2, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe máy kéo rơ-moóc không có đèn hậu ban đêm. Quan sát kỹ khi trời tối."),

        // Chapter 3: Đường cao tốc (44-63)
        HazardSituation(id: 44, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Xe phía trước phanh gấp trên cao tốc. Giữ khoảng cách ít nhất 100m."),
        HazardSituation(id: 45, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Xe tải chuyển làn đột ngột. Không đi trong điểm mù của xe lớn."),
        HazardSituation(id: 46, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe nhập làn từ đường nhánh vào cao tốc. Chuyển làn trái nhường đường nếu có thể."),
        HazardSituation(id: 47, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 13.0, perfectEnd: 16.0,
                         tip: "Vật cản trên đường cao tốc (lốp xe, hàng rơi). Quan sát xa và chuyển làn sớm."),
        HazardSituation(id: 48, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Xe đi chậm trên làn trái cao tốc gây ùn tắc. Vượt phải là vi phạm, kiên nhẫn chờ."),
        HazardSituation(id: 49, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Mưa lớn trên cao tốc giảm tầm nhìn và bám đường. Giảm tốc, bật đèn khẩn cấp."),
        HazardSituation(id: 50, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 12.5, perfectEnd: 15.5,
                         tip: "Xe container tạo luồng gió mạnh khi vượt. Giữ chặt tay lái khi đi song song."),
        HazardSituation(id: 51, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Tốc độ cao làm tăng quãng đường phanh. Ở 120km/h cần 100m+ để dừng hẳn."),
        HazardSituation(id: 52, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Xe phía trước đột ngột tránh vật cản. Giữ khoảng cách để có thời gian phản ứng."),
        HazardSituation(id: 53, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Nút giao cao tốc phức tạp. Quan sát biển báo từ xa, chuyển làn sớm."),
        HazardSituation(id: 54, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Xe dừng khẩn cấp trên làn đường cao tốc cực kỳ nguy hiểm. Chuyển làn tránh."),
        HazardSituation(id: 55, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Không lùi xe, quay đầu, hoặc đi ngược chiều trên cao tốc. Vi phạm rất nặng."),
        HazardSituation(id: 56, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Khi ra khỏi cao tốc, giảm tốc từ từ trên làn giảm tốc. Không phanh gấp."),
        HazardSituation(id: 57, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 14.067, perfectEnd: 16.932,
                         tip: "Hiệu ứng đường hầm: mắt cần thời gian thích ứng ánh sáng. Giảm tốc khi vào hầm."),
        HazardSituation(id: 58, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 12.789, perfectEnd: 15.644,
                         tip: "Xe máy lạc vào cao tốc rất nguy hiểm. Giữ khoảng cách và bấm còi cảnh báo."),
        HazardSituation(id: 59, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Tai nạn liên hoàn trên cao tốc do không giữ khoảng cách. Tập trung quan sát."),
        HazardSituation(id: 60, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Nổ lốp ở tốc độ cao: giữ tay lái, từ từ giảm tốc, không phanh gấp."),
        HazardSituation(id: 61, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Xe chạy quá chậm trên cao tốc cũng nguy hiểm. Tốc độ tối thiểu 60km/h."),
        HazardSituation(id: 62, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Khi gặp đoạn đường cao tốc bị ngập, giảm tốc tối đa và đi theo vệt xe trước."),
        HazardSituation(id: 63, title: "Bạn xử lý tình huống này như thế nào?", chapter: 3, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Gió ngang mạnh trên cầu cao tốc. Giữ chặt tay lái và giảm tốc."),

        // Chapter 4: Đường đèo núi (64-73)
        HazardSituation(id: 64, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Đường đèo dốc quanh co, xe ngược chiều có thể lấn làn. Bấm còi trước khúc cua."),
        HazardSituation(id: 65, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xuống dốc dài: sử dụng số thấp để hãm, không đạp phanh liên tục sẽ mất phanh."),
        HazardSituation(id: 66, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Đường đèo sương mù, tầm nhìn dưới 30m. Bật đèn vàng, bấm còi liên tục."),
        HazardSituation(id: 67, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Đá rơi, sạt lở trên đường đèo. Quan sát biển cảnh báo và mái taluy."),
        HazardSituation(id: 68, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Lên dốc phải nhường đường cho xe xuống dốc khi đường hẹp. Nháy đèn báo hiệu."),
        HazardSituation(id: 69, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Khúc cua tay áo trên đèo: giảm tốc trước khi vào cua, không phanh trong cua."),
        HazardSituation(id: 70, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe tải nặng xuống đèo mất phanh có thể lao sang làn đối diện. Cảnh giác."),
        HazardSituation(id: 71, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 12.5, perfectEnd: 15.5,
                         tip: "Đường đèo ban đêm: chỉ nhìn thấy trong tầm đèn pha. Không chạy quá 40km/h."),
        HazardSituation(id: 72, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Mặt đường đèo ướt sau mưa cực trơn. Giảm tốc 50% so với bình thường."),
        HazardSituation(id: 73, title: "Bạn xử lý tình huống này như thế nào?", chapter: 4, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Dốc cao, xe dừng giữa dốc có thể trôi ngược. Sử dụng phanh tay + chèn bánh."),

        // Chapter 5: Đường quốc lộ, tỉnh lộ (74-90)
        HazardSituation(id: 74, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Vượt xe trên quốc lộ: chỉ vượt bên trái, đảm bảo không có xe ngược chiều."),
        HazardSituation(id: 75, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe tải chạy chậm trên tỉnh lộ che khuất tầm nhìn. Không vượt nếu không chắc chắn."),
        HazardSituation(id: 76, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Ngã ba, ngã tư trên quốc lộ thường có xe từ đường phụ lao ra. Giảm tốc qua giao lộ."),
        HazardSituation(id: 77, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Xe khách dừng đón trả khách trên quốc lộ. Hành khách có thể chạy qua đường."),
        HazardSituation(id: 78, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Xe máy đi sát lề đường có thể bất ngờ tránh ổ gà và lấn ra giữa đường."),
        HazardSituation(id: 79, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Đường quốc lộ qua khu chợ: người bán hàng và khách lấn chiếm lòng đường."),
        HazardSituation(id: 80, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe ben chở đầy vật liệu có thể rơi vãi trên đường. Không đi sát phía sau."),
        HazardSituation(id: 81, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 12.5, perfectEnd: 15.5,
                         tip: "Đoạn đường đang thi công thu hẹp lòng đường. Giảm tốc theo biển chỉ dẫn."),
        HazardSituation(id: 82, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Trâu bò qua đường quốc lộ vùng nông thôn. Dừng hẳn chờ đàn gia súc qua."),
        HazardSituation(id: 83, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Đường hai làn ngược chiều: chỉ vượt khi có vạch nét đứt bên làn mình."),
        HazardSituation(id: 84, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 13.0, perfectEnd: 16.0,
                         tip: "Giao lộ có đèn nhấp nháy vàng: giảm tốc, quan sát và nhường đường bên phải."),
        HazardSituation(id: 85, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 11.506, perfectEnd: 13.887,
                         tip: "Ban đêm xe ngược chiều bật đèn pha gây chói mắt. Nhìn lệch phải, giảm tốc."),
        HazardSituation(id: 86, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe container phanh gấp trên đường trơn có thể mất lái xoay ngang. Giữ cự ly."),
        HazardSituation(id: 87, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Đường tỉnh lộ thường hẹp, không có dải phân cách. Cẩn thận xe ngược chiều."),
        HazardSituation(id: 88, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Xe ba gác chở hàng quá khổ chiếm gần hết làn đường. Bấm còi và vượt cẩn thận."),
        HazardSituation(id: 89, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Đường giao cắt đường sắt: dừng hẳn, quan sát cả hai hướng trước khi qua."),
        HazardSituation(id: 90, title: "Bạn xử lý tình huống này như thế nào?", chapter: 5, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Đoạn ngập nước trên quốc lộ: giảm tốc, đi số thấp, không dừng giữa vùng ngập."),

        // Chapter 6: Tình huống tai nạn thực tế (91-120)
        HazardSituation(id: 91, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Va chạm do không quan sát gương. Luôn kiểm tra gương trước khi chuyển làn."),
        HazardSituation(id: 92, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Tai nạn do vượt ẩu tại khúc cua. Không bao giờ vượt khi không thấy đường phía trước."),
        HazardSituation(id: 93, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Xe máy lách giữa hai ô tô rất nguy hiểm. Quan sát gương khi dừng đèn đỏ."),
        HazardSituation(id: 94, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Va chạm tại giao lộ do vượt đèn đỏ. Tuân thủ tín hiệu đèn là an toàn nhất."),
        HazardSituation(id: 95, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Tai nạn do sử dụng điện thoại khi lái xe. Dừng hẳn nếu cần nghe/gọi điện."),
        HazardSituation(id: 96, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Buồn ngủ là sát thủ thầm lặng. Dừng nghỉ 15 phút mỗi 2 giờ lái xe."),
        HazardSituation(id: 97, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Lái xe sau khi uống rượu bia, phản xạ chậm 2-3 lần. Tuyệt đối không lái."),
        HazardSituation(id: 98, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.923, perfectEnd: 13.456,
                         tip: "Lốp mòn, lốp non hơi giảm bám đường. Kiểm tra lốp thường xuyên."),
        HazardSituation(id: 99, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 12.310, perfectEnd: 15.050,
                         tip: "Tai nạn do không thắt dây an toàn. Dây an toàn giảm 50% nguy cơ tử vong."),
        HazardSituation(id: 100, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 9.600, perfectEnd: 12.320,
                         tip: "Va chạm liên hoàn do không giữ khoảng cách. Quy tắc 3 giây luôn đúng."),
        HazardSituation(id: 101, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Xe máy không đội mũ bảo hiểm gặp tai nạn chấn thương sọ não cao gấp 3 lần."),
        HazardSituation(id: 102, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Tai nạn do quay đầu xe không đúng nơi quy định. Chỉ quay đầu nơi cho phép."),
        HazardSituation(id: 103, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Va chạm với xe từ đường phụ. Xe trên đường chính có ưu tiên nhưng vẫn cần quan sát."),
        HazardSituation(id: 104, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Mở cửa xe không quan sát gây tai nạn cho xe máy. Dùng tay xa mở cửa để tự nhìn sau."),
        HazardSituation(id: 105, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Tai nạn do chạy quá tốc độ trên đường cong. Giảm tốc trước khi vào cua."),
        HazardSituation(id: 106, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Đâm vào dải phân cách khi tránh xe đột ngột. Không đánh lái gấp ở tốc độ cao."),
        HazardSituation(id: 107, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Phanh gấp trên đường ướt gây trượt bánh. Phanh nhẹ nhiều lần thay vì đạp mạnh."),
        HazardSituation(id: 108, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 12.5, perfectEnd: 15.5,
                         tip: "Va chạm khi lùi xe không quan sát. Luôn kiểm tra phía sau và dùng camera lùi."),
        HazardSituation(id: 109, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Tai nạn do xe tải mất phanh xuống dốc. Sử dụng làn thoát hiểm nếu có."),
        HazardSituation(id: 110, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Xe máy chở ba, lạng lách dễ mất thăng bằng. Giữ khoảng cách khi đi sau."),
        HazardSituation(id: 111, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 13.0, perfectEnd: 16.0,
                         tip: "Va chạm do không nhường đường xe ưu tiên. Dừng lại khi nghe còi xe khẩn cấp."),
        HazardSituation(id: 112, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Tai nạn khi đi vào đường ngược chiều. Quan sát biển báo một chiều cẩn thận."),
        HazardSituation(id: 113, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Xe tải ôm cua rộng cuốn xe máy vào gầm. Không đi sát xe lớn khi rẽ."),
        HazardSituation(id: 114, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Va chạm tại điểm giao cắt tầm nhìn hạn chế. Giảm tốc + bấm còi trước ngã rẽ."),
        HazardSituation(id: 115, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.5, perfectEnd: 13.5,
                         tip: "Xe khách lấn làn vượt xe tải gây tai nạn đối đầu. Hậu quả luôn nghiêm trọng."),
        HazardSituation(id: 116, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.5, perfectEnd: 14.5,
                         tip: "Tai nạn do đi vào vùng nước sâu. Không cố đi qua khi nước ngập quá nửa bánh."),
        HazardSituation(id: 117, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 9.5, perfectEnd: 12.5,
                         tip: "Va chạm khi trời mưa tầm nhìn kém. Bật đèn pha, gạt nước và giảm tốc."),
        HazardSituation(id: 118, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 10.0, perfectEnd: 13.0,
                         tip: "Đâm xe khi chạy theo đoàn không giữ khoảng cách. Mỗi xe cần khoảng cách riêng."),
        HazardSituation(id: 119, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 11.0, perfectEnd: 14.0,
                         tip: "Tai nạn do tài xế mệt mỏi, mất tập trung. Nghỉ ngơi đầy đủ trước khi lái."),
        HazardSituation(id: 120, title: "Bạn xử lý tình huống này như thế nào?", chapter: 6, perfectStart: 12.0, perfectEnd: 15.0,
                         tip: "Luôn quan sát 360 độ khi tham gia giao thông. Phòng thủ là cách lái an toàn nhất."),
    ]
    // swiftlint:enable function_body_length

    static func random(count: Int) -> [HazardSituation] {
        Array(all.shuffled().prefix(count))
    }
}
