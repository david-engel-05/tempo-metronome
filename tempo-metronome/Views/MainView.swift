import SwiftUI

struct MainView: View {
    @Environment(MetronomeState.self) private var state
    @Environment(MetronomeEngine.self) private var engine

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            beatIndicator

            Spacer()

            BPMControlView()

            Spacer()

            playStopButton

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Beat Indicator

    private var beatIndicator: some View {
        HStack(spacing: 14) {
            ForEach(0..<state.beatsPerBar, id: \.self) { beat in
                Circle()
                    .fill(dotColor(for: beat))
                    .frame(width: 18, height: 18)
                    .scaleEffect(isActiveBeat(beat) ? 1.3 : 1.0)
                    .animation(.easeOut(duration: 0.08), value: state.currentBeat)
            }
        }
    }

    // MARK: - Play/Stop Button

    private var playStopButton: some View {
        Button {
            if state.isPlaying {
                engine.stop()
            } else {
                engine.start()
            }
        } label: {
            Image(systemName: state.isPlaying ? "stop.fill" : "play.fill")
                .font(.system(size: 48))
                .foregroundStyle(.primary)
                .frame(width: 88, height: 88)
                .background(Color(.secondarySystemBackground))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func isActiveBeat(_ beat: Int) -> Bool {
        state.isPlaying && beat == state.currentBeat
    }

    private func dotColor(for beat: Int) -> Color {
        guard isActiveBeat(beat) else { return Color(.tertiaryLabel) }
        return beat == 0 ? .accentColor : .primary
    }
}

#Preview {
    let state = MetronomeState()
    MainView()
        .environment(state)
        .environment(MetronomeEngine(state: state))
}
