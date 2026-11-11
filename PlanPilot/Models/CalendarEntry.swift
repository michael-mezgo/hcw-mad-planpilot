//
//  CalendarEntry.swift
//  PlanPilot
//
//  Created by Michael Mezgolits on 02.11.26.
//

import FoundationModels

/// Structured output of the model. The `@Guide` descriptions define the format of each field.
@Generable
struct CalendarEntry {
    // Generated first so the model decides whether there is a plan before filling in any details
    @Guide(description: "true ONLY if the user's text describes a concrete plan with at least a destination, an activity or a day. false for empty, meaningless or unrelated text. If false, leave all other fields empty.")
    var hasPlan: Bool

    @Guide(description: "Short, neutral calendar title with at most 6 words that names the activity and, if given, the place, e.g. 'Day hike at Schneeberg'. Never use first person. Use the SAME language as the user input.")
    var title: String

    @Guide(description: "Name of the place or destination only, e.g. 'Schneeberg'. No country, no extra text. Empty string if the user named no place. Use the SAME language as the user input.")
    var location: String

    @Guide(description: """
        When the event happens, in English, using ONLY one of these forms:
        - relative: 'today', 'tomorrow', 'this <weekday>', 'next <weekday>' (e.g. 'next wednesday')
        - explicit date: '<day> <month name>' (e.g. '15 november'), add the year only if the user said it (e.g. '15 november 2027')
        Normalize numeric dates like '15.11.' or '15/11' to the explicit form.
        Use 'today' ONLY if the user explicitly wrote it (e.g. 'today', 'heute'). Never use it as a default.
        If the user named no day, no weekday and no date, return an empty string. Do NOT guess and do NOT assume today.
    """)
    var dayDescription: String

    // Generated last so the model can build the sentence from the fields above
    @Guide(description: "One neutral sentence summarizing the plan, e.g. 'Wednesday next week: day hike on Schneeberg.' Never use first person and do not address the user. Use the SAME language as the user input.")
    var summary: String
}
