import XCTest
import Quick

import KushiroTests

var tests = [XCTestCaseEntry]()
tests += KushiroTests.allTests()
XCTMain(tests)

var quickTests = [QuickSpec.Type]()
quickTests += KushiroTests.quickTests()
QCKMain(quickTests)
