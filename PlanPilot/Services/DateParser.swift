//
//  DateParser.swift
//  PlanPilot
//
//  Created by Michael Mezgolits on 02.11.26.
//  Supported by Claude Code (Sonnet 5.5)
//

import Foundation

/// Converts the model's `dayDescription` into an actual date.
/// The model never calculates dates itself, it only returns one of these fixed forms:
/// "today", "tomorrow", "this <weekday>", "next <weekday>", "15 november", "15 november 2027"
enum DateParser {
    private static let weekdays = [
        "sunday": 1, "monday": 2, "tuesday": 3, "wednesday": 4,
        "thursday": 5, "friday": 6, "saturday": 7,
    ]

    static func date(from description: String, relativeTo now: Date = .now) -> Date? {
        let text = description.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        switch text {
        case "":
            return nil
        case "today":
            return today
        case "tomorrow":
            return calendar.date(byAdding: .day, value: 1, to: today)
        default:
            break
        }

        let words = text.split(separator: " ").map(String.init)

        // "this wednesday" / "next wednesday"
        if words.count == 2, let weekday = weekdays[words[1]] {
            let components = DateComponents(weekday: weekday)
            switch words[0] {
            case "this":
                // Next occurrence, including today
                return calendar.nextDate(after: today.addingTimeInterval(-1), matching: components, matchingPolicy: .nextTime)
            case "next":
                // Occurrence in the following week: search starts at the beginning of next week
                guard let thisWeek = calendar.dateInterval(of: .weekOfYear, for: today) else { return nil }
                return calendar.nextDate(after: thisWeek.end.addingTimeInterval(-1), matching: components, matchingPolicy: .nextTime)
            default:
                return nil
            }
        }

        // "15 november 2027" (year given)
        if let date = parse(text, formats: ["d MMMM yyyy", "d MMM yyyy"]) {
            return date
        }

        // "15 november" (no year) -> next occurrence from today
        if let date = parse(text, formats: ["d MMMM", "d MMM"]) {
            let components = calendar.dateComponents([.month, .day], from: date)
            return calendar.nextDate(after: today.addingTimeInterval(-1), matching: components, matchingPolicy: .nextTime)
        }

        return nil
    }

    // en_US_POSIX because the model returns month names in English
    private static func parse(_ text: String, formats: [String]) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }
}
