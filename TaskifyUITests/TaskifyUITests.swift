import XCTest

final class TaskifyUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testAppLaunchesSuccessfully() throws {
        // Verify that the main window appears
        XCTAssertTrue(app.windows.firstMatch.exists)
    }

    func testAddTodoFlow() throws {
        // Assumes there's an "Add" button or similar UI to tap
        // Replace "Add" with the actual button label if different
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Verify that the input field appears
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 5))

        // Enter text and submit
        textField.tap()
        textField.typeText("Buy milk")
        app.keyboards.buttons["Return"].tap()

        // Verify that a new cell with the text appears in the list
        let cell = app.staticTexts["Buy milk"]
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testMarkTodoComplete() throws {
        // Precondition: there's at least one todo in the list
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

        // Swipe to complete (assuming swipe action marks done)
        firstCell.swipeRight()

        // Verify the cell is marked completed (customize predicate as needed)
        XCTAssertTrue(firstCell.isSelected || firstCell.staticTexts.element(boundBy: 0).label.contains("✓"))
    }

}
