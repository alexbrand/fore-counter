import SwiftUI

struct ContentView: View {
    @State private var viewModel = RoundViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 8) {
                Text("Hole \(viewModel.currentHoleNumber)")
                    .font(.headline)

                Text("\(viewModel.currentStrokes)")
                    .font(.system(size: 48, weight: .bold))

                Text("strokes")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                strokeButton
                nextHoleButton

                Text("Total: \(viewModel.totalStrokes)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .navigationDestination(isPresented: $viewModel.showScorecardSummary) {
                ScorecardView(viewModel: viewModel)
            }
        }
    }

    private var strokeButton: some View {
        Text("+ Stroke")
            .font(.body.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                viewModel.incrementStroke()
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                viewModel.decrementStroke()
            }
    }

    private var nextHoleButton: some View {
        Button("Next Hole →") {
            viewModel.nextHole()
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
}
