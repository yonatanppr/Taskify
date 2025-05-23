import XCTest
@testable import Taskify

final class TaskifyTests: XCTestCase {

    override func setUpWithError() throws {
        // Clear persisted todos before each test
        UserDefaults.standard.removeObject(forKey: "saved_todos")
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "saved_todos")
    }

    func testTodoStorageSaveAndLoad() throws {
        let todos = [
            TodoItem(title: "Test1"),
            TodoItem(title: "Test2", isDone: true),
            TodoItem(title: "Test3", reminderDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()))
        ]
        TodoStorage.save(todos)
        let loaded = TodoStorage.load()
        XCTAssertEqual(loaded.count, todos.count)
        XCTAssertEqual(loaded.map { $0.title }, todos.map { $0.title })
        XCTAssertEqual(loaded.map { $0.isDone }, todos.map { $0.isDone })
        XCTAssertEqual(loaded.map { $0.reminderDate != nil }, todos.map { $0.reminderDate != nil })
    }

    func testTodoItemIsTodayWhenDateIsToday() throws {
        var item = TodoItem(title: "TodayTest")
        item.reminderDate = Date()
        XCTAssertTrue(item.isToday)
    }

    func testTodoItemIsTodayWhenDateIsNotToday() throws {
        var item = TodoItem(title: "YesterdayTest")
        item.reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        XCTAssertFalse(item.isToday)
    }

    func testNormalizedReminderDateReturnsStartOfDay() throws {
        var item = TodoItem(title: "NormalizeTest")
        let now = Date()
        item.reminderDate = now
        let normalized = item.normalizedReminderDate
        let startOfDay = Calendar.current.startOfDay(for: now)
        XCTAssertEqual(normalized, startOfDay)
    }

}
