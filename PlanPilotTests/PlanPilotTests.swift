//
//  PlanPilotTests.swift
//  PlanPilotTests
//
//  Created by Michael Mezgolits on 01.11.26.
//

import Foundation
@testable import PlanPilot
import Testing

struct DateParserTests {
    private let calendar = Calendar.current

    // Fixed reference date: Tuesday, 10 November 2026
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 14))!
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func parse(_ text: String) -> Date? {
        DateParser.date(from: text, relativeTo: now)
    }

    @Test func todayAndTomorrow() {
        #expect(parse("today") == day(2026, 11, 10))
        #expect(parse("tomorrow") == day(2026, 11, 11))
    }

    @Test func ignoresCaseAndWhitespace() {
        #expect(parse("  Tomorrow \n") == day(2026, 11, 11))
    }

    @Test func thisWeekday() {
        #expect(parse("this wednesday") == day(2026, 11, 11))
        // Today counts as "this tuesday"
        #expect(parse("this tuesday") == day(2026, 11, 10))
        #expect(parse("this monday") == day(2026, 11, 16))
    }

    @Test func nextWeekdayIsInFollowingWeek() throws {
        let result = try #require(parse("next wednesday"))
        let thisWeek = try #require(calendar.dateInterval(of: .weekOfYear, for: now))

        #expect(calendar.component(.weekday, from: result) == 4)
        #expect(result >= thisWeek.end)
        #expect(result < thisWeek.end.addingTimeInterval(7 * 24 * 60 * 60))
    }

    @Test func explicitDateWithoutYear() {
        #expect(parse("15 november") == day(2026, 11, 15))
        // Already passed this year -> next year
        #expect(parse("5 november") == day(2027, 11, 5))
        #expect(parse("1 jan") == day(2027, 1, 1))
    }

    @Test func explicitDateWithYear() {
        #expect(parse("15 november 2027") == day(2027, 11, 15))
    }

    @Test(arguments: ["", "someday", "next funday", "in two weeks"])
    func invalidInputReturnsNil(_ text: String) {
        #expect(parse(text) == nil)
    }
}
