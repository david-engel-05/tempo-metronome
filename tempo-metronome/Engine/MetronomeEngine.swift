import AVFAudio
import Observation
import UIKit

@Observable
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

    // MARK: - Internal transport state (accessed only on schedulerQueue)

    private let schedulerQueue = DispatchQueue(label: "com.tempo.scheduler", qos: .userInteractive)
    private var isRunning = false   // source of truth for start/stop guard
    private var nextBeatIndex = 0   // internal beat counter

    // MARK: - Tap Tempo

    @ObservationIgnored private var tapTimestamps: [Date] = []

    // MARK: - Observable state (UI mirror)

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

        configureAudioSession()
        observeInterruptions()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            // Audio session setup failed — app will still work but may use wrong output
        }
    }

    private func observeInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            stop()
        case .ended:
            // Only auto-resume if the system says it's okay to do so
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt,
               AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                try? AVAudioSession.sharedInstance().setActive(true)
            }
        @unknown default:
            break
        }
    }

    // MARK: - Public API

    func start() {
        schedulerQueue.async { [weak self] in
            guard let self, !self.isRunning else { return }
            self.isRunning = true

            do {
                try self.engine.start()
            } catch {
                self.isRunning = false
                return
            }

            self.playerNode.play()

            // Seed the first beat slightly in the future for sample-accurate playback
            self.nextBeatHostTime = mach_absolute_time() + self.secondsToHostTicks(self.schedulerInterval)
            self.nextBeatIndex = 0

            self.scheduleBeats()
            self.startSchedulerTimer()

            DispatchQueue.main.async { [weak self] in
                self?.state.isPlaying = true
            }
        }
    }

    func stop() {
        schedulerQueue.async { [weak self] in
            guard let self, self.isRunning else { return }
            self.isRunning = false

            self.schedulerTimer?.cancel()
            self.schedulerTimer = nil
            self.nextBeatIndex = 0

            self.playerNode.stop()
            self.engine.stop()

            DispatchQueue.main.async { [weak self] in
                self?.state.isPlaying = false
                self?.state.currentBeat = 0
            }
        }
    }

    func updateBPM(_ bpm: Double) {
        state.bpm = min(300, max(20, bpm))
        // Ongoing scheduling reads state.bpm directly, so no restart needed
    }

    func recordTap() {
        let now = Date()

        if let last = tapTimestamps.last, now.timeIntervalSince(last) > 2.0 {
            tapTimestamps.removeAll()
        }

        tapTimestamps.append(now)

        if tapTimestamps.count > 8 {
            tapTimestamps.removeFirst()
        }

        guard tapTimestamps.count >= 2 else { return }

        var totalInterval: Double = 0
        for i in 1..<tapTimestamps.count {
            totalInterval += tapTimestamps[i].timeIntervalSince(tapTimestamps[i - 1])
        }
        let averageInterval = totalInterval / Double(tapTimestamps.count - 1)
        updateBPM(60.0 / averageInterval)
    }

    // MARK: - Scheduling

    private func startSchedulerTimer() {
        // Must be called on schedulerQueue
        let timer = DispatchSource.makeTimerSource(queue: schedulerQueue)
        timer.schedule(deadline: .now(), repeating: schedulerInterval)
        timer.setEventHandler { [weak self] in
            self?.scheduleBeats()
        }
        timer.resume()
        schedulerTimer = timer
    }

    private func scheduleBeats() {
        // Runs on schedulerQueue — reads/writes only internal properties
        let secondsPerBeat = 60.0 / state.bpm
        let beatDurationHostTicks = secondsToHostTicks(secondsPerBeat)
        let horizon = mach_absolute_time() + secondsToHostTicks(lookAheadDuration)

        while nextBeatHostTime < horizon {
            let beatTime = AVAudioTime(hostTime: nextBeatHostTime)
            let buffer = (nextBeatIndex == 0) ? accentBuffer! : normalBuffer!
            let beatIndex = nextBeatIndex

            playerNode.scheduleBuffer(buffer, at: beatTime, options: []) { [weak self] in
                guard let self, self.isRunning else { return }
                DispatchQueue.main.async {
                    self.state.currentBeat = beatIndex
                }
            }

            nextBeatHostTime += beatDurationHostTicks
            nextBeatIndex = (nextBeatIndex + 1) % state.beatsPerBar
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
