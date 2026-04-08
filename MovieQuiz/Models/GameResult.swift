import Foundation

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetter(than other: GameResult) -> Bool {
        return correct > other.correct
    }
}
