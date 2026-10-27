import SwiftUI

struct SubmitPinView: View {
    let pin: Pin
    let explorer: Explorer

    @EnvironmentObject var apiService: APIService
    @Environment(\.dismiss) var dismiss

    @State private var completionDate = Date()
    @State private var supervisingAdult = ""
    @State private var note = ""
    @State private var supervisionConfirmed = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text(pin.name)
                        .font(.headline)
                }

                Section("Explorer") {
                    Text("\(explorer.firstName) \(explorer.lastName)")
                    Text(explorer.circle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Date completed") {
                    DatePicker("", selection: $completionDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }

                Section("Supervising adult") {
                    TextField("Name", text: $supervisingAdult)
                }

                Section("What did you do? (optional)") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }

                if let supervision = pin.supervision, supervision.contains("supervision") {
                    Section {
                        Toggle(isOn: $supervisionConfirmed) {
                            Text("I was there and supervised this activity, as this pin requires.")
                                .font(.subheadline)
                        }
                    }
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Submit Pin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send to Pin Wizard") {
                        Task {
                            await submitPin()
                        }
                    }
                    .disabled(!canSubmit)
                }
            }
            .disabled(isSubmitting)
            .overlay {
                if isSubmitting {
                    ProgressView()
                }
            }
        }
    }

    private var canSubmit: Bool {
        !supervisingAdult.isEmpty &&
        (!pin.supervision!.contains("supervision") || supervisionConfirmed)
    }

    private func submitPin() async {
        isSubmitting = true
        errorMessage = nil

        do {
            try await apiService.submitPin(
                explorer: explorer,
                pin: pin.name,
                supervisingAdult: supervisingAdult,
                note: note.isEmpty ? nil : note
            )

            await MainActor.run {
                isSubmitting = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}

#Preview {
    SubmitPinView(
        pin: Pin(
            name: "Knife Safety",
            journey: .west,
            supervision: "Adult supervision",
            requirements: "Demonstrate safe knife handling.",
            examples: nil,
            imageURL: nil,
            imageURLs: nil
        ),
        explorer: Explorer(circle: "Vikings", lastName: "Doe", firstName: "John", adventureName: nil)
    )
    .environmentObject(APIService.shared)
}
