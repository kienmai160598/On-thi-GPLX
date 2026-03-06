import SwiftUI

// MARK: - Topic

struct Topic: Identifiable, Hashable {
    /// Stable key derived from `topicIds`, used as the `Identifiable` id.
    var id: String { key }

    /// One or more source topic IDs from the question data.
    let topicIds: [Int]
    let name: String
    let shortName: String
    let icon: String          // SF Symbol name
    let color: Color
    var questionCount: Int

    /// Stable key used for routing and storage (e.g. "1_2").
    var key: String {
        topicIds.map(String.init).joined(separator: "_")
    }

    // MARK: - Static catalogue (5 tabs — topic 1+2 merged, then 3, 4, 5, 6)

    static let all: [Topic] = [
        Topic(
            topicIds: [1, 2],
            name: "Quy định & Văn hoá",
            shortName: "Quy định",
            icon: "text.book.closed",
            color: .topicQuyDinh,
            questionCount: 0
        ),
        Topic(
            topicIds: [3],
            name: "Kỹ thuật lái xe",
            shortName: "Kỹ thuật",
            icon: "car",
            color: .topicKyThuat,
            questionCount: 0
        ),
        Topic(
            topicIds: [4],
            name: "Cấu tạo & Sửa chữa",
            shortName: "Cấu tạo",
            icon: "wrench.and.screwdriver",
            color: .topicCauTao,
            questionCount: 0
        ),
        Topic(
            topicIds: [5],
            name: "Biển báo đường bộ",
            shortName: "Biển báo",
            icon: "exclamationmark.triangle",
            color: .topicBienBao,
            questionCount: 0
        ),
        Topic(
            topicIds: [6],
            name: "Sa hình & Tình huống",
            shortName: "Sa hình",
            icon: "map",
            color: .topicSaHinh,
            questionCount: 0
        ),
    ]

    /// Map a question's topic integer to its group key (e.g. 1 -> "1_2").
    static func keyForTopicId(_ topicId: Int) -> String {
        for topic in all {
            if topic.topicIds.contains(topicId) {
                return topic.key
            }
        }
        return String(topicId)
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(topicIds)
    }

    static func == (lhs: Topic, rhs: Topic) -> Bool {
        lhs.topicIds == rhs.topicIds
    }

    /// Alias for `icon` — views reference `sfSymbol`.
    var sfSymbol: String { icon }

    /// Short description of what this topic covers.
    var topicDescription: String {
        switch topicIds.first {
        case 1: return "Luật giao thông, quy tắc ứng xử và đạo đức người lái xe"
        case 3: return "Kỹ năng lái xe an toàn và xử lý tình huống trên đường"
        case 4: return "Cấu tạo xe ô tô, bảo dưỡng và sửa chữa cơ bản"
        case 5: return "Nhận biết và hiểu ý nghĩa các loại biển báo giao thông"
        case 6: return "Xử lý tình huống giao thông qua hình ảnh mô phỏng"
        default: return ""
        }
    }

    // MARK: - Copy helper

    func withQuestionCount(_ count: Int) -> Topic {
        var copy = self
        copy.questionCount = count
        return copy
    }
}
