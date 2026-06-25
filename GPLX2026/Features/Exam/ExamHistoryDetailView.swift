import SwiftUI

struct ExamHistoryDetailView: View {
    @Environment(QuestionStore.self) private var questionStore

    let result: ExamResult

    /// Rebuild questions and answers together so their indices stay aligned.
    /// `questionStore.questions(byNos:)` uses `compactMap`, silently dropping
    /// any question whose `no` is absent from the store. Building both arrays
    /// in a single pass ensures that `answers[i]` always matches `questions[i]`.
    private var questionsAndAnswers: ([Question], [Int: Int]) {
        let nos = result.questionDetails.map(\.questionNo)
        let fetched = questionStore.questions(byNos: nos)
        let byNo: [Int: Question] = Dictionary(fetched.map { ($0.no, $0) },
                                               uniquingKeysWith: { first, _ in first })
        var qs: [Question] = []
        var dict: [Int: Int] = [:]
        for detail in result.questionDetails {
            guard let question = byNo[detail.questionNo] else { continue }
            let index = qs.count
            qs.append(question)
            if let answerId = detail.selectedAnswerId {
                dict[index] = answerId
            }
        }
        return (qs, dict)
    }

    var body: some View {
        let (qs, ans) = questionsAndAnswers
        return ExamResultView(
            questions: qs,
            answers: ans,
            timeUsedSeconds: result.timeUsedSeconds,
            examResult: result,
            isFromHistory: true
        )
    }
}
