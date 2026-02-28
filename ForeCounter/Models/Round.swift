import Foundation

struct Round: Codable, Equatable {
    var holes: [HoleScore]
    let startedAt: Date

    init() {
        self.holes = [HoleScore(holeNumber: 1)]
        self.startedAt = Date()
    }

    var currentHole: HoleScore {
        holes[holes.count - 1]
    }

    var totalStrokes: Int {
        holes.reduce(0) { $0 + $1.strokes }
    }
}
