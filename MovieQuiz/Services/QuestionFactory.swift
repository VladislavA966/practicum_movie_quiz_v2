import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    let moviesLoader: MoviesLoadingProtocol
    
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    
    func fetchData() {
        moviesLoader.fetchMovies {
            [weak self] result in
            guard let selft = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self?.movies = mostPopularMovies.items
                self?.delegate?.didLoadDataFromServer()
            case .failure(let error):
                self?.delegate?.didFailToLoadData(with: error)
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async {[weak self] in
            
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(
                imageName:  imageData,
                text: text,
                isCorrect: correctAnswer,
            )
            
            DispatchQueue.main.async {
                [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
            
            
        }
        
    }
}



//    private let questions = [
//        QuizQuestion(
//            imageName: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: true
//        ),
//        QuizQuestion(
//            imageName: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: true
//        ),
//        QuizQuestion(
//            imageName: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: true
//        ),
//        QuizQuestion(
//            imageName: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: true
//        ),
//        QuizQuestion(
//            imageName: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: true
//        ),
//        QuizQuestion(
//            imageName: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: true
//        ),
//        QuizQuestion(
//            imageName: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: false
//        ),
//        QuizQuestion(
//            imageName: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: false
//        ),
//        QuizQuestion(
//            imageName: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: false
//        ),
//        QuizQuestion(
//            imageName: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            isCorrect: false
//        ),
//    ]
