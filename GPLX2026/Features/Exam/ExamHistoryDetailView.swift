import SwiftUI

struct ExamHistoryDetailView: View {
    @Environment(QuestionStore.self) private var questionStore

    let result: ExamResult

    private var questions: [Question] {
        questionStore.questions(byNos: result.questionDetails.map(\.questionNo))
    }

    private var answers: [Int: Int] {
        var dict: [Int: Int] = [:]
        for (i, detail) in result.questionDetails.enumerated() {
            if let answerId = detail.selectedAnswerId {
                dict[i] = answerId
            }
        }
        return dict
    }

    var body: some View {
        ExamResultView(
            questions: questions,
            answers: answers,
            timeUsedSeconds: result.timeUsedSeconds,
            examResult: result,
            isFromHistory: true
        )
    }
}
