import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EtsyThingsBridge2Tests.allTests),
    ]
}
#endif