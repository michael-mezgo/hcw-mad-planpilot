//
//  PlanPilotUITests.swift
//  PlanPilotUITests
//
//  Created by Michael Mezgolits on 01.11.26.
//

import XCTest

final class PlanPilotUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
