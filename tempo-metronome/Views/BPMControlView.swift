import SwiftUI

struct BPMControlView: View {
    @Environment(MetronomeState.self) private var state
    @Environment(MetronomeEngine.self) private var engine

    @State private var isEditingBPM = false
    @State private var bpmInput = ""
    @FocusState private var inputFocused: Bool
    @State private var tapScale: Double = 1.0

    var body: some View {
        VStack(spacing: 24) {
            bpmDisplay
            stepperAndSlider
            tapTempoButton
        }
    }

    // MARK: - BPM Display

    private var bpmDisplay: some View {
        VStack(spacing: 4) {
            if isEditingBPM {
                TextField("BPM", text: $bpmInput)
                    .font(.system(size: 80, weight: .thin, design: .rounded))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($inputFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("OK") { commitBPM() }
                        }
                    }
            } else {
                Text("\(Int(state.bpm))")
                    .font(.system(size: 80, weight: .thin, design: .rounded))
                    .onTapGesture { startEditing() }
            }

            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Stepper + Slider

    private var stepperAndSlider: some View {
        HStack(spacing: 16) {
            stepperButton(systemImage: "minus") {
                engine.updateBPM(state.bpm - 1)
            }

            Slider(
                value: Binding(get: { state.bpm }, set: { engine.updateBPM($0) }),
                in: 20...300,
                step: 1
            )

            stepperButton(systemImage: "plus") {
                engine.updateBPM(state.bpm + 1)
            }
        }
    }

    private func stepperButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 44, height: 44)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tap Tempo

    private var tapTempoButton: some View {
        Button {
            engine.recordTap()
            withAnimation(.easeOut(duration: 0.1)) { tapScale = 0.93 }
            withAnimation(.easeOut(duration: 0.1).delay(0.1)) { tapScale = 1.0 }
        } label: {
            Text("TAP")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .scaleEffect(tapScale)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Editing

    private func startEditing() {
        bpmInput = "\(Int(state.bpm))"
        isEditingBPM = true
        inputFocused = true
    }

    private func commitBPM() {
        if let value = Double(bpmInput) {
            engine.updateBPM(value)
        }
        isEditingBPM = false
        inputFocused = false
    }
}

#Preview {
    let state = MetronomeState()
    BPMControlView()
        .environment(state)
        .environment(MetronomeEngine(state: state))
        .padding()
}
