import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            
        }
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBAction private func onYesButtonTap(_ sender: UIButton) {
        checkResultAndGoToNextQuestion(true)
    }
    
    @IBOutlet private weak var questionImage: UIImageView!
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBAction private func onNoButtonTap(_ sender: UIButton) {
        checkResultAndGoToNextQuestion(false)
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private let alertPresenter = AlertPresenter()
    
    private var statisticsService: StatisticsServiceProtocol?
    
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticsService = StatisticsService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoading(), delegate: self)
        showLoadingIndicator()
        questionFactory?.fetchData()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data:    model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func checkResultAndGoToNextQuestion(_ givenAnswer: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        guard currentQuestionIndex != questionsAmount - 1 else {
            setUpResultAlert()
            return
        }
        
        showResul(
            isCorrect: givenAnswer == currentQuestion.isCorrect
        )
    }
    
    private func showResul(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        setImageBordersStyle(isCorrect ? UIColor.ypGreen : UIColor.ypRed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
            }
        }
        
    }
    
    private func setImageBordersStyle(_ color: UIColor = UIColor.clear) {
        questionImage.layer.masksToBounds = true
        questionImage.layer.borderWidth = 8
        questionImage.layer.borderColor = color.cgColor
        questionImage.layer.cornerRadius = 20
    }
    
    private func setUpResultAlert() {
        
        let previousBest = statisticsService?.bestGame
        
        statisticsService?.store(
            correct: correctAnswers,
            total: questionsAmount
        )
        
        let isNewRecord = correctAnswers > (previousBest?.correct ?? 0)
        
        let message = makeResultMessage(isNewRecod: isNewRecord)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonTitle: "Сыграть еще раз",
            completion: {
                [weak self] in
                guard let self = self else { return }
                restartGame()
            }
            
        )
        
        alertPresenter.show(vc: self, model: alertModel)
        
    }
    
    private func makeResultMessage(isNewRecod: Bool) -> String {
        let currentResultMessage =
        correctAnswers == questionsAmount
        ? "Поздравляем, вы ответили на 10 из 10!"
        : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
        
        let totalGamesCountMessage =
        "Количество сыгранных квизов: \(statisticsService?.gamesCount ?? 0)"
        
        let formattedDate = formatDate(
            (statisticsService?.bestGame.date ?? Date())
        )
        
        let recordMessage =
        isNewRecod
        ? "Это ваш новый рекорд!"
        : "Рекорд: \(statisticsService?.bestGame.correct ?? 0)/10 (\(formattedDate))"
        
        let accuracyMessage =
        "Средняя точность: \(String(format: "%.2f", (statisticsService?.totalAccuracy ?? 0.0)))%"
        
        return """
            \(currentResultMessage)
            \(totalGamesCountMessage)
            \(recordMessage)
            \(accuracyMessage)
            """
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter
    }()
    
    private func restartGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.fetchData()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    private func show(quiz: QuizStepViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.questionLabel.text = quiz.question
            self.questionImage.image = quiz.image
            self.counterLabel.text = quiz.questionNumber
            self.setImageBordersStyle()
        }
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    private func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            let alertModel = AlertModel(
                title: "Ошибка",
                message: message,
                buttonTitle: "Попробовать еще раз",
                completion: {
                    [weak self] in
                    guard let self = self else { return }
                    restartGame()
                }
                
            )
            
            alertPresenter.show(vc: self, model: alertModel)
        }
        
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
