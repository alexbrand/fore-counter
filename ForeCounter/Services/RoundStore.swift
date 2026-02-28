import Foundation

protocol RoundStoring {
    func save(_ round: Round)
    func load() -> Round?
    func clear()
}

final class RoundStore: RoundStoring {
    private let defaults: UserDefaults
    private let key = "activeRound"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ round: Round) {
        if let data = try? JSONEncoder().encode(round) {
            defaults.set(data, forKey: key)
        }
    }

    func load() -> Round? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Round.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
