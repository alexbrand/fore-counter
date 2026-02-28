import Foundation

struct HoleScore: Codable, Equatable, Identifiable {
    var id: Int { holeNumber }
    let holeNumber: Int
    var strokes: Int

    init(holeNumber: Int, strokes: Int = 0) {
        self.holeNumber = holeNumber
        self.strokes = strokes
    }
}
