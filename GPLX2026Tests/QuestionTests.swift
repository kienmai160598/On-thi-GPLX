import XCTest
@testable import GPLX2026

final class QuestionTests: XCTestCase {

    private func question(no: Int) -> Question {
        Question(
            no: no,
            text: "Q\(no)",
            answers: [
                Answer(id: 1, text: "A", correct: true),
                Answer(id: 2, text: "B", correct: false),
                Answer(id: 3, text: "C", correct: false),
                Answer(id: 4, text: "D", correct: false),
            ],
            topic: 1
        )
    }

    func testShuffledAnswersIsDeterministicPerQuestion() {
        let q = question(no: 42)
        let first = q.shuffledAnswers.map(\.id)
        let second = q.shuffledAnswers.map(\.id)
        XCTAssertEqual(first, second, "Seeded shuffle must be stable across calls")
    }

    func testShuffledAnswersIsAPermutationOfAnswers() {
        let q = question(no: 7)
        XCTAssertEqual(Set(q.shuffledAnswers.map(\.id)), Set(q.answers.map(\.id)))
        XCTAssertEqual(q.shuffledAnswers.count, q.answers.count)
    }

    func testDiemLietFlag() {
        var q = question(no: 1)
        XCTAssertFalse(q.isDiemLiet)
        q = Question(no: 2, text: "", answers: [], topic: 1, required1: 1)
        XCTAssertTrue(q.isDiemLiet)
    }
}
