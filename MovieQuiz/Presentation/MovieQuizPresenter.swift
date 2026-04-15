import Foundation
import UIKit

final class MovieQuizPresenter {
    
  let questionsAmount = 10
  var currentQuestion: QuizQuestion?
  weak var vc: MovieQuizViewController?
  private var currentQuestionIndex = 0
  private let alertPresenter = AlertPresenter()
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        guard let vc = vc else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {
            vc.show(quiz: viewModel)
        }
    }

    
    func onYesButtonPressed() {
        onButtonPressed(true)
    }
    
    func onNoButtonPressed() {
        onButtonPressed(false)
    }
    
   private func onButtonPressed(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        guard let vc = vc else { return }
        
        if isLastQuestion() {
            vc.setUpResultAlert()
        } else {
            vc.showResult(
                isCorrect: givenAnswer == currentQuestion.isCorrect
            )
        }
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.imageName,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    
    func isLastQuestion() -> Bool {
        questionsAmount == currentQuestionIndex - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}

