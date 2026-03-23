import Foundation

private enum Keys: String {
    case gamesCount
    case bestGame
    case totalCorrectAnswers
    case totalQuestionsAsked
}

class StatisticsService: StatisticsServiceProtocol {

    private let storage: UserDefaults = .standard

    private var totalCorrectAnswersCount: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }

        set {
            storage.set(
                totalCorrectAnswersCount + newValue,
                forKey: Keys.totalCorrectAnswers.rawValue
            )
        }
    }

    private var totalQuestionsAskedCount: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(
                totalQuestionsAskedCount + newValue,
                forKey: Keys.totalQuestionsAsked.rawValue
            )
        }
    }

    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }

        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            guard let data = storage.data(forKey: Keys.bestGame.rawValue),
                let result = try? JSONDecoder().decode(
                    GameResult.self,
                    from: data
                )
            else {
                return GameResult(correct: 0, total: 0, date: Date())
            }
            return result
        }

        set {

            let currentBest = bestGame

            if newValue.isBetter(than: currentBest) {
                if let data = try? JSONEncoder().encode(newValue) {
                    storage.set(data, forKey: Keys.bestGame.rawValue)
                }
            }
        }
    }

    var totalAccuracy: Double {
        let total = totalQuestionsAskedCount
        guard total > 0 else { return 0 }

        return (Double(totalCorrectAnswersCount) / Double(total)) * 100
    }

    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalQuestionsAskedCount = amount
        totalCorrectAnswersCount = count

        let newGame = GameResult(correct: count, total: amount, date: Date())

        bestGame = newGame
    }
}
