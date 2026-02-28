import Testing
import Foundation
@testable import ForeCounterKit

private final class MockRoundStore: RoundStoring {
    private var savedRound: Round?
    var saveCount = 0

    func save(_ round: Round) {
        savedRound = round
        saveCount += 1
    }

    func load() -> Round? {
        savedRound
    }

    func clear() {
        savedRound = nil
    }
}

@Suite("RoundViewModel logic tests")
struct RoundViewModelTests {
    @Test("New view model starts at hole 1 with 0 strokes")
    func initialState() {
        let vm = RoundViewModel(store: MockRoundStore())
        #expect(vm.currentHoleNumber == 1)
        #expect(vm.currentStrokes == 0)
        #expect(vm.totalStrokes == 0)
        #expect(vm.showScorecardSummary == false)
    }

    @Test("Increment stroke increases current strokes")
    func incrementStroke() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke()
        #expect(vm.currentStrokes == 1)
        vm.incrementStroke()
        #expect(vm.currentStrokes == 2)
    }

    @Test("Decrement stroke decreases current strokes")
    func decrementStroke() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke()
        vm.incrementStroke()
        vm.decrementStroke()
        #expect(vm.currentStrokes == 1)
    }

    @Test("Decrement stroke does not go below 0")
    func decrementFloorAtZero() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.decrementStroke()
        #expect(vm.currentStrokes == 0)
    }

    @Test("Next hole advances hole number and resets strokes")
    func nextHole() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke()
        vm.incrementStroke()
        vm.incrementStroke()
        vm.nextHole()
        #expect(vm.currentHoleNumber == 2)
        #expect(vm.currentStrokes == 0)
        #expect(vm.totalStrokes == 3)
    }

    @Test("After 18 holes, next hole shows scorecard")
    func scorecardAfter18() {
        let vm = RoundViewModel(store: MockRoundStore())
        for _ in 1..<18 {
            vm.incrementStroke()
            vm.nextHole()
        }
        #expect(vm.currentHoleNumber == 18)
        #expect(vm.showScorecardSummary == false)

        vm.nextHole()
        #expect(vm.showScorecardSummary == true)
        // Still on hole 18 — no hole 19
        #expect(vm.currentHoleNumber == 18)
    }

    @Test("New round resets everything")
    func newRound() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke()
        vm.nextHole()
        vm.incrementStroke()
        vm.incrementStroke()
        vm.newRound()
        #expect(vm.currentHoleNumber == 1)
        #expect(vm.currentStrokes == 0)
        #expect(vm.totalStrokes == 0)
        #expect(vm.showScorecardSummary == false)
    }

    @Test("Total strokes accumulates across holes")
    func totalAcrossHoles() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke() // hole 1: 1
        vm.nextHole()
        vm.incrementStroke() // hole 2: 1
        vm.incrementStroke() // hole 2: 2
        vm.nextHole()
        vm.incrementStroke() // hole 3: 1
        #expect(vm.totalStrokes == 4)
    }

    @Test("State persists through save and restore")
    func persistence() {
        let store = MockRoundStore()
        let vm1 = RoundViewModel(store: store)
        vm1.incrementStroke()
        vm1.incrementStroke()
        vm1.nextHole()
        vm1.incrementStroke()

        let vm2 = RoundViewModel(store: store)
        #expect(vm2.currentHoleNumber == 2)
        #expect(vm2.currentStrokes == 1)
        #expect(vm2.totalStrokes == 3)
    }

    @Test("Every mutation triggers a save")
    func savesOnEveryMutation() {
        let store = MockRoundStore()
        let vm = RoundViewModel(store: store)
        #expect(store.saveCount == 0)

        vm.incrementStroke()
        #expect(store.saveCount == 1)

        vm.decrementStroke()
        #expect(store.saveCount == 2)

        vm.nextHole()
        #expect(store.saveCount == 3)

        vm.newRound()
        #expect(store.saveCount == 4)
    }

    @Test("Next hole with 0 strokes is allowed")
    func nextHoleWithZeroStrokes() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.nextHole()
        #expect(vm.currentHoleNumber == 2)
        #expect(vm.round.holes[0].strokes == 0)
    }

    @Test("Repeated nextHole at hole 18 keeps showing scorecard without crashing")
    func repeatedNextHoleAt18() {
        let vm = RoundViewModel(store: MockRoundStore())
        for _ in 1..<18 {
            vm.nextHole()
        }
        #expect(vm.currentHoleNumber == 18)

        vm.nextHole()
        #expect(vm.showScorecardSummary == true)

        // Calling again should not crash or add a hole 19
        vm.nextHole()
        #expect(vm.showScorecardSummary == true)
        #expect(vm.currentHoleNumber == 18)
        #expect(vm.round.holes.count == 18)
    }

    @Test("Multiple newRound calls in sequence are safe")
    func multipleNewRounds() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke()
        vm.nextHole()
        vm.newRound()
        vm.newRound()
        vm.newRound()
        #expect(vm.currentHoleNumber == 1)
        #expect(vm.currentStrokes == 0)
        #expect(vm.totalStrokes == 0)
    }

    @Test("High stroke count on a single hole")
    func highStrokeCount() {
        let vm = RoundViewModel(store: MockRoundStore())
        for _ in 0..<100 {
            vm.incrementStroke()
        }
        #expect(vm.currentStrokes == 100)
        #expect(vm.totalStrokes == 100)
    }

    @Test("Decrement after increment returns to original count")
    func incrementThenDecrementIsIdentity() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke()
        vm.incrementStroke()
        vm.incrementStroke()
        vm.decrementStroke()
        vm.decrementStroke()
        vm.decrementStroke()
        #expect(vm.currentStrokes == 0)
    }

    @Test("Decrement does not save when already at 0")
    func decrementAtZeroDoesNotSave() {
        let store = MockRoundStore()
        let vm = RoundViewModel(store: store)
        let countBefore = store.saveCount
        vm.decrementStroke()
        #expect(store.saveCount == countBefore)
    }

    @Test("newRound after scorecard clears showScorecardSummary")
    func newRoundClearsScorecardFlag() {
        let vm = RoundViewModel(store: MockRoundStore())
        for _ in 1..<18 {
            vm.nextHole()
        }
        vm.nextHole() // triggers scorecard
        #expect(vm.showScorecardSummary == true)

        vm.newRound()
        #expect(vm.showScorecardSummary == false)
        #expect(vm.currentHoleNumber == 1)
    }

    @Test("Full round with varied strokes per hole")
    func fullRoundVariedStrokes() {
        let vm = RoundViewModel(store: MockRoundStore())
        var expectedTotal = 0
        for hole in 1...18 {
            let strokes = (hole % 5) + 2 // varies 2-6
            for _ in 0..<strokes {
                vm.incrementStroke()
            }
            expectedTotal += strokes
            if hole < 18 {
                vm.nextHole()
            }
        }
        #expect(vm.round.holes.count == 18)
        #expect(vm.totalStrokes == expectedTotal)

        vm.nextHole()
        #expect(vm.showScorecardSummary == true)
    }

    @Test("Persistence survives a full round and new round")
    func persistenceFullCycle() {
        let store = MockRoundStore()
        let vm1 = RoundViewModel(store: store)
        for _ in 1..<18 {
            vm1.incrementStroke()
            vm1.nextHole()
        }
        vm1.incrementStroke()
        vm1.newRound()

        let vm2 = RoundViewModel(store: store)
        #expect(vm2.currentHoleNumber == 1)
        #expect(vm2.currentStrokes == 0)
        #expect(vm2.totalStrokes == 0)
    }

    @Test("Strokes on previous holes are not affected by current hole actions")
    func previousHolesImmutable() {
        let vm = RoundViewModel(store: MockRoundStore())
        vm.incrementStroke()
        vm.incrementStroke()
        vm.incrementStroke() // hole 1: 3
        vm.nextHole()
        vm.incrementStroke() // hole 2: 1

        #expect(vm.round.holes[0].strokes == 3)
        #expect(vm.round.holes[1].strokes == 1)

        vm.decrementStroke() // hole 2: 0
        #expect(vm.round.holes[0].strokes == 3) // hole 1 unchanged
        #expect(vm.round.holes[1].strokes == 0)
    }
}
