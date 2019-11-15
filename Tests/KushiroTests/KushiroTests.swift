import XCTest
@testable import Kushiro

final class KushiroTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Kushiro().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
