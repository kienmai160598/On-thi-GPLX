import Foundation

/// The learner's self-reported study experience, collected in onboarding so the
/// app can tune its recommendations. A soft preference — never a hard gate.
enum ExperienceLevel: String, CaseIterable, Codable {
    case beginner
    case partial
    case cramming

    var icon: String {
        switch self {
        case .beginner: "leaf.fill"
        case .partial:  "chart.line.uptrend.xyaxis"
        case .cramming: "target"
        }
    }

    var title: String {
        switch self {
        case .beginner: "Mới bắt đầu"
        case .partial:  "Đã ôn một phần"
        case .cramming: "Ôn lại trước ngày thi"
        }
    }

    var subtitle: String {
        switch self {
        case .beginner: "Chưa từng ôn thi lý thuyết"
        case .partial:  "Đã nắm cơ bản, cần luyện thêm"
        case .cramming: "Đã sẵn sàng, muốn ôn cấp tốc"
        }
    }
}
