import SwiftUI

struct BPMControlView: View {
    @Environment(MetronomeState.self) private var state
    @Environment(MetronomeEngine.self) private var engine

    @State private var isEditingBPM = false
    @State private var bpmInput = ""
    @FocusState private var inputFocused: Bool
    @State private var tapTimestamps: [Date] = []

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
        Button(action: handleTap) {
            Text("TAP")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func handleTap() {
        let now = Date()

        // Reset if last tap was more than 2 seconds ago
        if let last = tapTimestamps.last, now.timeIntervalSince(last) > 2.0 {
            tapTimestamps.removeAll()
        }

        tapTimestamps.append(now)

        // Rolling window: keep only the last 8 taps
        if tapTimestamps.count > 8 {
            tapTimestamps.removeFirst()
        }

        // Need at least 2 taps to calculate a BPM
        guard tapTimestamps.count >= 2 else { return }

        // BPM = 60 / average interval between consecutive taps
        var totalInterval: Double = 0
        for i in 1..<tapTimestamps.count {
            totalInterval += tapTimestamps[i].timeIntervalSince(tapTimestamps[i - 1])
        }
        let averageInterval = totalInterval / Double(tapTimestamps.count - 1)
        engine.updateBPM(60.0 / averageInterval)
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
