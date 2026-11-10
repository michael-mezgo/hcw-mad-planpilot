//
//  ModelStatus.swift
//  PlanPilot
//
//  Created by Michael Mezgolits on 01.11.26.
//

/// Availability of the on-device model, decoupled from the FoundationModels framework
/// so the view does not need to know about it.
enum ModelStatus {
    case available
    case deviceNotEligible
    case notEnabled
    case notReady
    case unknown
}
