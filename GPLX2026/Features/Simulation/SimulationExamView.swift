import SwiftUI

struct SimulationExamView: View {
    let mode: Mode

    enum Mode {
        case random
        case fullPractice
        case examSet(Int)
    }

    var body: some View {
        BaseExamView(mode: .simulation(mode))
    }
}
