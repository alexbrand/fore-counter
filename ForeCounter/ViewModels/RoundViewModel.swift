import Foundation
import Observation

@Observable
final class RoundViewModel {
    private let store: RoundStoring

    var round: Round
    var showScorecardSummary = false

    var currentHoleNumber: Int { round.currentHole.holeNumber }
    var currentStrokes: Int { round.currentHole.strokes }
    var totalStrokes: Int { round.totalStrokes }

    init(store: RoundStoring = RoundStore()) {
        self.store = store
        self.round = store.load() ?? Round()
    }

    func incrementStroke() {
        round.holes[round.holes.count - 1].strokes += 1
        store.save(round)
    }

    func decrementStroke() {
        guard round.currentHole.strokes > 0 else { return }
        round.holes[round.holes.count - 1].strokes -= 1
        store.save(round)
    }

    func nextHole() {
        if round.holes.count < 18 {
            let next = HoleScore(holeNumber: round.holes.count + 1)
            round.holes.append(next)
            store.save(round)
        } else {
            showScorecardSummary = true
        }
    }

    func newRound() {
        round = Round()
        showScorecardSummary = false
        store.save(round)
    }
}
