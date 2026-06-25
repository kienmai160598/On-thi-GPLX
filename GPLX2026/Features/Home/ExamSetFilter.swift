import Foundation

/// Filter for the fixed exam-set list on the Thi thử (mock exam) tab.
enum ExamSetFilter: String, CaseIterable {
    case all       = "Tất cả"
    case attempted = "Đã thi"
    case notTried  = "Chưa thi"
}
