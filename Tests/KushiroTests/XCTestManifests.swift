import XCTest
import Quick

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(InMemoryKeyValueStoreTests.allTests),
    ]
}
#endif

#if !canImport(ObjectiveC)
public func quickTests() -> [QuickSpec.Type] {
    return [
        RangeDBTests.self
    ]
}
#endif
