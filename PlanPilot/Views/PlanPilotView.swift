//
//  PlanPilotView.swift
//  PlanPilot
//
//  Created by Michael Mezgolits on 01.11.26.
//

import SwiftUI

struct PlanPilotView: View {
    @State private var viewModel = PlanPilotViewModel()

    var body: some View {
        NavigationStack {
            // Die View kennt nur den Status, nicht das Framework dahinter
            switch viewModel.modelAvailable {
            case .available:
                mainView
            case .deviceNotEligible:
                fallbackView("This device does not support Apple Intelligence.")
            case .notEnabled:
                fallbackView("Please enable Apple Intelligence in Settings.")
            case .notReady:
                fallbackView("The model is still loading. Please try again later.")
            case .unknown:
                fallbackView("The language model is not available.")
            }
        }
    }

    private var mainView: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 16) {
            TextField("e.g. Hiking at the Schneeberg next Wednesday",
                      text: $viewModel.input, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            Button("Plan") {
                Task { await viewModel.plan() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.input.isEmpty || viewModel.isLoading)

            ScrollView {
                Text(viewModel.output)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .navigationTitle("PlanPilot")
    }

    private func fallbackView(_ message: String) -> some View {
        ContentUnavailableView("Not Available",
                               systemImage: "exclamationmark.triangle",
                               description: Text(message))
    }
}

#Preview {
    PlanPilotView()
}
