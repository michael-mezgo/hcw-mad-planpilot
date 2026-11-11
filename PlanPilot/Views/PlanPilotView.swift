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
            // The view only knows the status, not the framework behind it
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

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            if viewModel.noPlanFound {
                ContentUnavailableView("No Plan Found",
                                       systemImage: "calendar.badge.exclamationmark",
                                       description: Text("Describe what you want to do, where and when."))
            }

            // Fields appear one after another while the model is streaming
            if let entry = viewModel.entry {
                Form {
                    Section("Summary") {
                        Text(entry.summary ?? "…")
                    }

                    Section("Details") {
                        field("Title", entry.title)
                        field("Location", entry.location)
                        if viewModel.isLoading {
                            field("Date", nil)
                        } else {
                                let dateText = viewModel.date?.formatted(date: .complete, time: .omitted)
                            field("Date", dateText ?? "—")
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("PlanPilot")
    }

    // While streaming the value is still nil -> show "…" as placeholder
    private func field(_ label: LocalizedStringKey, _ value: String?) -> some View {
        LabeledContent(label) {
            Text(value ?? "…")
        }
    }

    private func fallbackView(_ message: LocalizedStringKey) -> some View {
        ContentUnavailableView("Not Available",
                               systemImage: "exclamationmark.triangle",
                               description: Text(message))
    }
}

#Preview {
    PlanPilotView()
}
