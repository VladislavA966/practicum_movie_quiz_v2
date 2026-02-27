import UIKit

final class MovieQuizViewController: UIViewController {

    private struct QuizQuestion {
        let image: String
        let text: String
        let isCorrect: Bool
    }

    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String

    }

    private var questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: true
        ),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: true
        ),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: true
        ),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: true
        ),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: true
        ),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: true
        ),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: false
        ),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: false
        ),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: false
        ),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            isCorrect: false
        ),
    ]

    private var currentQuestionIndex = 0

    private var correctAnswers = 0

    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var questionLabel: UILabel!

    @IBOutlet private weak var yesButton: UIButton!

    @IBAction private func onYesButtonTap(_ sender: UIButton) {
        checkResultAndGoToNextQuestion(true)
    }

    @IBOutlet weak var questionImage: UIImageView!

    @IBOutlet weak var noButton: UIButton!

    @IBAction func onNoButtonTap(_ sender: UIButton) {
        checkResultAndGoToNextQuestion(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }

    private func setUpUI() {
        let currentQuestion = convert(model: questions[currentQuestionIndex])
        questionLabel.text = currentQuestion.question
        questionImage.image = currentQuestion.image
        counterLabel.text = currentQuestion.questionNumber
        setBorderColor(UIColor.white)
    }

    private func checkResultAndGoToNextQuestion(_ givenAnswer: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        guard currentQuestionIndex != questions.count - 1 else {
            setUpResultAlert()
            return
        }
        showResul(
            isCorrect: givenAnswer == questions[currentQuestionIndex].isCorrect
        )

    }

    private func showResul(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        setBorderColor(isCorrect ? UIColor.green : UIColor.red)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex += 1
            self.setUpUI()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }

    }

    private func setBorderColor(_ color: UIColor) {
        questionImage.layer.masksToBounds = true
        questionImage.layer.borderWidth = 1
        questionImage.layer.borderColor = color.cgColor
        questionImage.layer.cornerRadius = 6
    }

    private func setUpResultAlert() {
        let alert = UIAlertController(
            title: "Этот раунд окончен!",
            message: "Ваш результат \(correctAnswers)/10",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Сыграть еще раз", style: .default) {
            _ in
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questions = self.questions.shuffled()
            self.setUpUI()

        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }

}

/*
 Mock-данные


 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
