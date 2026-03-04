import SwiftUI

// MARK: - Hero Destination

enum HeroDestination: Hashable, Identifiable {
    case badges
    case topic(String)

    var id: String {
        switch self {
        case .badges: "badges"
        case .topic(let key): "topic_\(key)"
        }
    }
}
