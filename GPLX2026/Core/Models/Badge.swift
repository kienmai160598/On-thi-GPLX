import SwiftUI

// MARK: - BadgeType

enum BadgeType: String, CaseIterable, Codable {
    case streak7
    case streak30
    case allTopics
    case exam10Pass
    case accuracy90
    case diemLietMaster
    case questions100
    case questions300
    case questions600
}

// MARK: - AppBadge

struct AppBadge: Identifiable {
    var id: BadgeType { type }

    let type: BadgeType
    let title: String
    let description: String
    let icon: String            // SF Symbol name
    let color: Color
    let threshold: Int

    /// Alias for `icon` — views reference `sfSymbol`.
    var sfSymbol: String { icon }

    // MARK: - Full catalogue (matches Flutter version)

    static let all: [AppBadge] = [
        AppBadge(
            type: .streak7,
            title: "7 ngày",
            description: "Học 7 ngày liên tiếp",
            icon: "flame.fill",
            color: Color(hex: 0xFF6B35),
            threshold: 7
        ),
        AppBadge(
            type: .streak30,
            title: "30 ngày",
            description: "Học 30 ngày liên tiếp",
            icon: "flame.fill",
            color: Color(hex: 0xE53935),
            threshold: 30
        ),
        AppBadge(
            type: .questions100,
            title: "100 câu",
            description: "Trả lời đúng 100 câu",
            icon: "checkmark.circle.fill",
            color: Color(hex: 0x43A047),
            threshold: 100
        ),
        AppBadge(
            type: .questions300,
            title: "300 câu",
            description: "Trả lời đúng 300 câu",
            icon: "checkmark.seal.fill",
            color: Color(hex: 0x1E88E5),
            threshold: 300
        ),
        AppBadge(
            type: .questions600,
            title: "600 câu",
            description: "Trả lời đúng 600 câu",
            icon: "medal.fill",
            color: Color(hex: 0xFFB300),
            threshold: 600
        ),
        AppBadge(
            type: .allTopics,
            title: "Đủ chủ đề",
            description: "Hoàn thành tất cả chủ đề",
            icon: "graduationcap.fill",
            color: Color(hex: 0x7B1FA2),
            threshold: 1
        ),
        AppBadge(
            type: .exam10Pass,
            title: "10 lần đạt",
            description: "Đạt 10 bài thi thử",
            icon: "trophy.fill",
            color: Color(hex: 0xFF8F00),
            threshold: 10
        ),
        AppBadge(
            type: .accuracy90,
            title: "90% chính xác",
            description: "Độ chính xác trung bình ≥ 90%",
            icon: "sparkles",
            color: Color(hex: 0xE91E63),
            threshold: 90
        ),
        AppBadge(
            type: .diemLietMaster,
            title: "Master điểm liệt",
            description: "Đúng tất cả câu điểm liệt",
            icon: "shield.fill",
            color: Color(hex: 0x00897B),
            threshold: 1
        ),
    ]
}

// MARK: - BadgeStatus

struct BadgeStatus: Identifiable {
    var id: BadgeType { badge.type }

    let badge: AppBadge
    let isUnlocked: Bool
    let progress: Int
    let target: Int

    /// Progress fraction from 0.0 to 1.0.
    var fraction: Double {
        guard target > 0 else { return 0 }
        return min(Double(progress) / Double(target), 1.0)
    }
}

/// Views reference `BadgeDefinition` — alias to `AppBadge`.
typealias BadgeDefinition = AppBadge
