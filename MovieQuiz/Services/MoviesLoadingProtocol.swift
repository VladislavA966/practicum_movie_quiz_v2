import Foundation

protocol MoviesLoadingProtocol {
    func fetchMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}


struct MoviesLoading: MoviesLoadingProtocol {
    
    private let route = "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
    private let networkClient = NetworkClient()
    
    func fetchMovies(handler: @escaping (Result<MostPopularMovies, any Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) {
            result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
}
