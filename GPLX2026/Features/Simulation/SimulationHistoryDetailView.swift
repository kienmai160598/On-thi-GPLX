import SwiftUI

struct SimulationHistoryDetailView: View {
    @Environment(QuestionStore.self) private var questionStore

    let result: SimulationResult

    private var questions: [Question] {
        questionStore.questions(byNos: result.scenarioDetails.map(\.questionNo))
    }

    private var answers: [Int: Int] {
        var dict: [Int: Int] = [:]
        for (i, detail) in result.scenarioDetails.enumerated() {
            if let answerId = detail.selectedAnswerId {
                dict[i] = answerId
            }
        }
        return dict
    }

    private var timePerScenario: [Int: Int] {
        var dict: [Int: Int] = [:]
        for (i, detail) in result.scenarioDetails.enumerated() {
            dict[i] = detail.timeUsedSeconds
        }
        return dict
    }

    var body: some View {
        SimulationResultView(
            questions: questions,
            answers: answers,
            timePerScenario: timePerScenario,
            simulationResult: result,
            isFromHistory: true
        )
    }
}
