import Foundation

// MARK: - MemoryTip

struct MemoryTip: Codable, Identifiable {
    /// Use title as the stable identity (unique within each topic).
    var id: String { title }

    let title: String
    let content: String
}
