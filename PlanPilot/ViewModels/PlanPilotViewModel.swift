//
//  PlanPilotViewModel.swift
//  PlanPilot
//
//  Created by Michael Mezgolits on 01.11.26.
//

import Foundation
import FoundationModels
import Observation

@Observable
@MainActor // ViewModel changes UI state -> has to run on main thread
final class PlanPilotViewModel {
    var input: String = ""
    var entry: CalendarEntry.PartiallyGenerated? // Fields are optional because they are filled in one by one while streaming
    var errorMessage: String?
    var noPlanFound: Bool = false

    var isLoading: Bool = false

    // The date is calculated by Swift, not by the model. It is nil while streaming.
    var date: Date? {
        entry?.dayDescription.flatMap { DateParser.date(from: $0) }
    }

    private let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)

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
        entry = nil
        errorMessage = nil
        noPlanFound = false
        defer { isLoading = false }

        // Input without any letters (e.g. ".") can't contain a plan -> don't ask the model at all,
        // otherwise it tends to invent one
        guard input.contains(where: \.isLetter) else {
            noPlanFound = true
            return
        }

        // The output format comes from the @Generable struct, the instructions only control what gets extracted
        let session = LanguageModelSession(instructions: """
        You are a planning assistant.
        Today's date is \(Date.now.formatted(date: .complete, time: .omitted)).

        The user's text may contain many unrelated thoughts, corrections, other trips and errands. Find the ONE final plan they commit to.

        Rules:
        - Write title, location and summary in the language of the user's text.
        - Extract only the single event the user finally decides on.
        - If the user corrects themselves, the LAST statement wins. Ignore cancelled or rejected ideas.
        - Ignore other trips, errands, appointments, opinions and small talk.
        - Never combine details from different plans.
        - If a detail is not clearly stated for this plan, leave it empty.
        - Never invent a destination, date or activity.
        - If the text contains no concrete plan (no destination, activity or day), set hasPlan to false and leave all other fields empty.
        """)

        do {
            // partial.content is cumulative -> assign, don't append
            for try await partial in session.streamResponse(to: input, generating: CalendarEntry.self) {
                // hasPlan is generated first -> stop as soon as the model says there is no plan
                if partial.content.hasPlan == false {
                    entry = nil
                    noPlanFound = true
                    break
                }
                entry = partial.content
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
