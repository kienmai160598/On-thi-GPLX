import Foundation

enum LicenseType: String, CaseIterable, Codable {
    case b1 = "b1"
    case b2 = "b2"

    var displayName: String {
        switch self {
        case .b1: return "B1"
        case .b2: return "B2"
        }
    }

    var description: String {
        switch self {
        case .b1: return "Xe ô tô chở người đến 9 chỗ (không kinh doanh)"
        case .b2: return "Xe ô tô chở người đến 9 chỗ, xe tải dưới 3.5 tấn"
        }
    }

    // MARK: - Exam rules

    var questionsPerExam: Int {
        switch self {
        case .b1: return 30
        case .b2: return 35
        }
    }

    var totalTimeSeconds: Int {
        switch self {
        case .b1: return 20 * 60  // 20 minutes
        case .b2: return 22 * 60  // 22 minutes
        }
    }

    var passThreshold: Int {
        switch self {
        case .b1: return 26
        case .b2: return 32
        }
    }

    var diemLietPerExam: Int { 1 }

    var urgencyThresholdSeconds: Int { 300 }

    var totalExamSets: Int {
        switch self {
        case .b1: return 10   // 300 / 30
        case .b2: return 17   // 600 / 35 ≈ 17
        }
    }

    var totalQuestions: Int {
        switch self {
        case .b1: return 300
        case .b2: return 600
        }
    }

    // MARK: - Current

    static var current: LicenseType {
        let raw = UserDefaults.standard.string(forKey: AppConstants.StorageKey.licenseType) ?? "b2"
        return LicenseType(rawValue: raw) ?? .b2
    }
}
