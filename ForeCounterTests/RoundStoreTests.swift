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

    @Test("Full 18-hole round survives save and load")
    func full18HoleRoundTrip() {
        let (store, _) = makeStore()
        var round = Round()
        round.holes[0].strokes = 4
        for i in 2...18 {
            round.holes.append(HoleScore(holeNumber: i, strokes: i + 1))
        }

        store.save(round)
        let loaded = store.load()

        #expect(loaded != nil)
        #expect(loaded?.holes.count == 18)
        #expect(loaded == round)
    }

    @Test("Load returns nil for corrupted data")
    func corruptedData() {
        let (store, defaults) = makeStore()
        defaults.set(Data("not valid json".utf8), forKey: "activeRound")

        #expect(store.load() == nil)
    }

    @Test("startedAt is preserved through save and load")
    func startedAtPreserved() {
        let (store, _) = makeStore()
        let round = Round()
        store.save(round)

        let loaded = store.load()
        #expect(loaded?.startedAt == round.startedAt)
    }

    @Test("Clear on empty store does not crash")
    func clearWhenEmpty() {
        let (store, _) = makeStore()
        store.clear()
        #expect(store.load() == nil)
    }

    @Test("Multiple saves and loads stay consistent")
    func multipleSaveLoadCycles() {
        let (store, _) = makeStore()
        for i in 1...5 {
            var round = Round()
            round.holes[0].strokes = i
            store.save(round)

            let loaded = store.load()
            #expect(loaded?.holes[0].strokes == i)
        }
    }
}
