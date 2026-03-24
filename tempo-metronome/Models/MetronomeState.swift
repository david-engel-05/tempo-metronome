import Observation

@Observable
final class MetronomeState {
    var bpm: Double = 120.0
    var beatsPerBar: Int = 4
    var isPlaying: Bool = false
    var currentBeat: Int = 0  // 0-based, updated on every beat
}
