import Foundation
import XCTest

@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoadingMovies() throws {
        //Given
        let mockNetWorkClient = MockNetwokClient(emulateError: false)
        let loader = MoviesLoading(networkClient: mockNetWorkClient)

        //When
        let expectation = expectation(description: "Loading expectation")

        loader.fetchMovies { result in
            switch result {
            //Then
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Unnexpected error: \(error)")

            }
        }
        waitForExpectations(timeout: 1)
    }

    func testErrorLoadingMovies() throws {
        //Given
        let mockNetWorkClient = MockNetwokClient(emulateError: true)
        let loader = MoviesLoading(networkClient: mockNetWorkClient)

        //When
        let expectation = expectation(description: "Loading expectation")

        loader.fetchMovies { result in
            switch result {
            //Then
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success(_):
                XCTFail("Expected to fail but got success")

            }
        }
        waitForExpectations(timeout: 1)

    }
}
