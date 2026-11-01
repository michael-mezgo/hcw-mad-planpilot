//
//  PlanPilotViewModel.swift
//  PlanPilot
//
//  Created by Michael Mezgolits on 01.11.26.
//

import FoundationModels
import SwiftUI

@Observable
@MainActor // ViewModel changes UI state -> has to run on main thread
final class PlanPilotViewModel {
    var input: String = ""
    var output: String = "" // TODO: Calendar event

    var isLoading: Bool = false

    private let model = SystemLanguageModel.default
    private let language = Locale.current.localizedString(forIdentifier: Locale.current.identifier) ?? "English"

    var modelAvailable: ModelStatus {
        switch model.availability {
        case .available:
            ModelStatus.available
        case let .unavailable(reason):
            switch reason {
            case .deviceNotEligible:
                ModelStatus.deviceNotEligible
            case .appleIntelligenceNotEnabled:
                ModelStatus.notEnabled
            case .modelNotReady:
                ModelStatus.notReady
            default:
                ModelStatus.unknown
            }
        }
    }

    func plan() async {
        isLoading = true
        defer { isLoading = false }

        let session = LanguageModelSession(instructions: """
        You are a planning assistant.                                           
        Today's date is \(Date.now.formatted(date: .complete, time: .omitted)) .

        The user's text may contain many unrelated thoughts, corrections, other trips and errands. Find the ONE final plan they commit to.

        Rules:
        - Extract only the single event the user finally decides on.
        - If the user corrects themselves, the LAST statement wins. Ignore cancelled or rejected ideas.
        - Ignore other trips, errands, appointments, opinions and small talk.
        - Never combine details from different plans.
        - If a detail is not clearly stated for this plan, leave it empty.)
        - Never write in first person.
        - Describe the plan neutrally, e.g. "Wednesday next week: day hike on Schneeberg."
        - Do not address the user either.
        - If the text contains no concrete plan (no destination, activity or date), answer exactly: NO_PLAN
        - Never invent a destination, date or activity.
        - Always answer in the user's preferred language: \(language)
        """)

        do {
            for try await partial in session.streamResponse(to: input) {
                output = "\(partial.content) - LANGUAGE: \(language)"
            }
        } catch {
            output = error.localizedDescription
        }
    }
}

enum ModelStatus {
    case available
    case deviceNotEligible
    case notEnabled
    case notReady
    case unknown
}
