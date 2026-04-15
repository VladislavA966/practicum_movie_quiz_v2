import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() throws {
       try buttonTests(buttonId: "Yes")
    }
    
    func testNoButton() throws {
       try buttonTests(buttonId: "No")
    }
    
    func testGameResult() throws {
        sleep(2)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let alert = app.alerts["Этот раунд окончен!"]
         sleep(2)
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    
    func testCloseAlert () throws {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        let alert = app.alerts["Этот раунд окончен!"]
        sleep(2)
        alert.buttons["Сыграть еще раз"].tap()
        let indexLabel = app.staticTexts["Index"]
        sleep(2)
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
    
    private func buttonTests(buttonId: String) throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        app.buttons[buttonId].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    //    @MainActor
    //    func testExample() throws {
    //        let app = XCUIApplication()
    //        app.launch()
    //    }
    //
    //    @MainActor
    //    func testLaunchPerformance() throws {
    //        measure(metrics: [XCTApplicationLaunchMetric()]) {
    //            XCUIApplication().launch()
    //        }
    //    }

}
