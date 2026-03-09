import SwiftUI

struct MockExamView: View {
    let examSetId: Int?

    init(examSetId: Int? = nil) {
        self.examSetId = examSetId
    }

    var body: some View {
        BaseExamView(mode: .mockExam(examSetId: examSetId))
    }
}
