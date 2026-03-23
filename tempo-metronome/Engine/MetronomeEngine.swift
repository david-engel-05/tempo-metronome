import AVFAudio
import Observation

final class MetronomeEngine {

    // MARK: - Configuration

    private let lookAheadDuration: Double = 0.3   // schedule beats up to 300ms ahead
    private let schedulerInterval: Double = 0.05  // wake up every 50ms

    // MARK: - Audio

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let audioFormat: AVAudioFormat

    private var accentBuffer: AVAudioPCMBuffer!   // beat 1
    private var normalBuffer: AVAudioPCMBuffer!   // beats 2+

    // MARK: - Timing

    private var schedulerTimer: DispatchSourceTimer?
    private var nextBeatHostTime: UInt64 = 0
    private var sampleRate: Double { audioFormat.sampleRate }

    // MARK: - State

    private let state: MetronomeState

    // MARK: - Init

    init(state: MetronomeState) {
        self.state = state

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        self.audioFormat = format

        accentBuffer = makeClickBuffer(frequency: 1000, durationSeconds: 0.030, format: format)
        normalBuffer = makeClickBuffer(frequency: 800, durationSeconds: 0.020, format: format)

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
    }

    // MARK: - Public API

    func start() {
        guard !state.isPlaying else { return }

        do {
            try engine.start()
        } catch {
            return
        }

        playerNode.play()

        // Schedule the first beat immediately
        let now = AVAudioTime(hostTime: mach_absolute_time())
        nextBeatHostTime = now.hostTime

        scheduleBeats()
        startSchedulerTimer()

        DispatchQueue.main.async { [weak self] in
            self?.state.isPlaying = true
        }
    }

    func stop() {
        schedulerTimer?.cancel()
        schedulerTimer = nil

        playerNode.stop()
        engine.stop()

        DispatchQueue.main.async { [weak self] in
            self?.state.isPlaying = false
            self?.state.currentBeat = 0
        }
    }

    func updateBPM(_ bpm: Double) {
        state.bpm = min(300, max(20, bpm))
        // Ongoing scheduling uses state.bpm directly, so no restart needed
    }

    // MARK: - Scheduling

    private func startSchedulerTimer() {
        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .userInteractive))
        timer.schedule(deadline: .now(), repeating: schedulerInterval)
        timer.setEventHandler { [weak self] in
            self?.scheduleBeats()
        }
        timer.resume()
        schedulerTimer = timer
    }

    private func scheduleBeats() {
        let secondsPerBeat = 60.0 / state.bpm
        let beatDurationHostTicks = secondsToHostTicks(secondsPerBeat)
        let lookAheadTicks = secondsToHostTicks(lookAheadDuration)
        let nowTicks = mach_absolute_time()
        let horizon = nowTicks + lookAheadTicks

        while nextBeatHostTime < horizon {
            let beatTime = AVAudioTime(hostTime: nextBeatHostTime)
            let buffer = (state.currentBeat == 0) ? accentBuffer! : normalBuffer!

            playerNode.scheduleBuffer(buffer, at: beatTime, options: [], completionHandler: nil)

            let beatIndex = state.currentBeat
            DispatchQueue.main.async { [weak self] in
                self?.state.currentBeat = beatIndex
            }

            // Advance to next beat
            nextBeatHostTime = nextBeatHostTime + beatDurationHostTicks
            let nextBeat = (state.currentBeat + 1) % state.beatsPerBar
            DispatchQueue.main.async { [weak self] in
                self?.state.currentBeat = nextBeat
            }
        }
    }

    // MARK: - Sound Generation

    private func makeClickBuffer(frequency: Double, durationSeconds: Double, format: AVAudioFormat) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(format.sampleRate * durationSeconds)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let channelData = buffer.floatChannelData![0]
        let decayFrames = Double(frameCount)

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / format.sampleRate
            let envelope = 1.0 - (Double(frame) / decayFrames)  // linear decay
            channelData[frame] = Float(sin(2.0 * .pi * frequency * t) * envelope * 0.8)
        }

        return buffer
    }

    // MARK: - Time Conversion

    private func secondsToHostTicks(_ seconds: Double) -> UInt64 {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        let nanoseconds = seconds * 1_000_000_000
        return UInt64(nanoseconds * Double(info.denom) / Double(info.numer))
    }
}
