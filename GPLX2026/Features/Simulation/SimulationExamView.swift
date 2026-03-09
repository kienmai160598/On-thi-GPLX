import SwiftUI

struct SimulationExamView: View {
    let mode: Mode

    enum Mode {
        case random
        case fullPractice
    }

    var body: some View {
        BaseExamView(mode: .simulation(mode))
    }
}
