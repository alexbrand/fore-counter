import Testing
import Foundation
@testable import ForeCounterKit

@Suite("RoundStore persistence tests")
struct RoundStoreTests {
    private func makeStore() -> (RoundStore, UserDefaults) {
        let suiteName = "com.forecounter.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = RoundStore(defaults: defaults)
        return (store, defaults)
    }

    @Test("Save and load round-trips a round")
    func saveAndLoad() {
        let (store, _) = makeStore()
        var round = Round()
        round.holes[0].strokes = 5
        round.holes.append(HoleScore(holeNumber: 2, strokes: 3))

        store.save(round)
        let loaded = store.load()

        #expect(loaded != nil)
        #expect(loaded == round)
    }

    @Test("Load returns nil when nothing saved")
    func loadReturnsNilWhenEmpty() {
        let (store, _) = makeStore()
        #expect(store.load() == nil)
    }

    @Test("Clear removes stored round")
    func clearRemovesRound() {
        let (store, _) = makeStore()
        store.save(Round())
        store.clear()
        #expect(store.load() == nil)
    }

    @Test("Save overwrites previous round")
    func saveOverwrites() {
        let (store, _) = makeStore()
        var first = Round()
        first.holes[0].strokes = 1
        store.save(first)

        var second = Round()
        second.holes[0].strokes = 99
        store.save(second)

        let loaded = store.load()
        #expect(loaded?.holes[0].strokes == 99)
    }
}
