import SwiftUI

struct AnswerTileList: View {
    let answers: [Answer]
    let selectedAnswerId: Int?
    var isConfirmed: Bool = false
    var showCorrectness: Bool = false
    let onSelect: (Answer) -> Void

    var body: some View {
        ForEach(Array(answers.enumerated()), id: \.element.id) { index, answer in
            let letter = ["A", "B", "C", "D"][min(index, 3)]
            let isSelected = selectedAnswerId == answer.id

            Button {
                onSelect(answer)
            } label: {
                AnswerOptionCard(
                    letter: letter,
                    text: answer.text,
                    isSelected: isSelected,
                    isConfirmed: showCorrectness ? isConfirmed : false,
                    isCorrect: answer.correct
                )
            }
            .disabled(showCorrectness && isConfirmed)
            .padding(.bottom, 10)
        }
    }
}
