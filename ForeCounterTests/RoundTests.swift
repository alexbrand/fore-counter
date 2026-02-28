import Testing
@testable import ForeCounterKit

@Suite("Round and HoleScore model tests")
struct RoundTests {
    @Test("New round starts with hole 1 at 0 strokes")
    func newRoundDefaults() {
        let round = Round()
        #expect(round.holes.count == 1)
        #expect(round.holes[0].holeNumber == 1)
        #expect(round.holes[0].strokes == 0)
    }

    @Test("Current hole returns the last hole")
    func currentHoleIsLast() {
        var round = Round()
        round.holes.append(HoleScore(holeNumber: 2, strokes: 3))
        #expect(round.currentHole.holeNumber == 2)
        #expect(round.currentHole.strokes == 3)
    }

    @Test("Total strokes sums all holes")
    func totalStrokes() {
        var round = Round()
        round.holes[0].strokes = 4
        round.holes.append(HoleScore(holeNumber: 2, strokes: 5))
        round.holes.append(HoleScore(holeNumber: 3, strokes: 3))
        #expect(round.totalStrokes == 12)
    }

    @Test("HoleScore identity is based on hole number")
    func holeScoreIdentity() {
        let a = HoleScore(holeNumber: 7, strokes: 3)
        let b = HoleScore(holeNumber: 7, strokes: 5)
        #expect(a.id == b.id)
    }

    @Test("HoleScore equality checks strokes")
    func holeScoreEquality() {
        let a = HoleScore(holeNumber: 1, strokes: 3)
        let b = HoleScore(holeNumber: 1, strokes: 5)
        #expect(a != b)

        let c = HoleScore(holeNumber: 1, strokes: 3)
        #expect(a == c)
    }

    @Test("Round is Codable")
    func roundCodable() throws {
        var round = Round()
        round.holes[0].strokes = 4
        round.holes.append(HoleScore(holeNumber: 2, strokes: 6))

        let data = try JSONEncoder().encode(round)
        let decoded = try JSONDecoder().decode(Round.self, from: data)
        #expect(decoded == round)
    }
}
