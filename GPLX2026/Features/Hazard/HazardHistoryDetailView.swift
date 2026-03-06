import SwiftUI

struct HazardHistoryDetailView: View {
    let result: HazardResult

    private var situations: [HazardSituation] {
        result.details.compactMap { detail in
            HazardSituation.all.first(where: { $0.id == detail.situationId })
        }
    }

    private var tapTimes: [Int: Double?] {
        var dict: [Int: Double?] = [:]
        for (i, detail) in result.details.enumerated() {
            dict[i] = detail.tapTime
        }
        return dict
    }

    var body: some View {
        HazardResultView(
            situations: situations,
            tapTimes: tapTimes,
            result: result,
            isFromHistory: true
        )
    }
}
