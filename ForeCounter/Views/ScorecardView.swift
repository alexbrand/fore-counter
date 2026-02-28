import SwiftUI

struct ScorecardView: View {
    var viewModel: RoundViewModel

    var body: some View {
        List {
            ForEach(viewModel.round.holes) { hole in
                HStack {
                    Text("Hole \(hole.holeNumber)")
                    Spacer()
                    Text("\(hole.strokes)")
                        .bold()
                }
            }

            HStack {
                Text("Total")
                    .bold()
                Spacer()
                Text("\(viewModel.totalStrokes)")
                    .bold()
            }
            .listRowBackground(Color.accentColor.opacity(0.2))
        }
        .navigationTitle("Scorecard")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("New Round") {
                    viewModel.newRound()
                }
            }
        }
    }
}
