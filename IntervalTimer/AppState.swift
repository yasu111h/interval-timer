import Foundation
import AppKit

struct StopwatchItem: Identifiable {
    let id = UUID()
    var elapsedSeconds: Int = 0
    var isRunning: Bool = false

    var formatted: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
}

struct IntervalTimerState {
    var nextAlarmSeconds: Int = 0
    var isRunning: Bool = false
    var selectedInterval: Int = 5

    var nextAlarmFormatted: String {
        let m = nextAlarmSeconds / 60
        let s = nextAlarmSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

class AppState: ObservableObject {
    @Published var stopwatches: [StopwatchItem] = [StopwatchItem()]
    @Published var intervalTimer = IntervalTimerState()

    let intervals = [1, 5, 10, 15, 20, 30, 60]
    private var ticker: Timer?

    init() {
        ticker = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(ticker!, forMode: .common)
    }

    private func tick() {
        for i in stopwatches.indices where stopwatches[i].isRunning {
            stopwatches[i].elapsedSeconds += 1
        }
        guard intervalTimer.isRunning else { return }
        intervalTimer.nextAlarmSeconds -= 1
        if intervalTimer.nextAlarmSeconds <= 0 {
            playAlarm()
            intervalTimer.nextAlarmSeconds = intervalTimer.selectedInterval * 60
        }
    }

    // MARK: - Stopwatch

    func addStopwatch() {
        guard stopwatches.count < 3 else { return }
        stopwatches.append(StopwatchItem())
    }

    func removeStopwatch(_ id: UUID) {
        stopwatches.removeAll { $0.id == id }
    }

    func toggleStopwatch(_ id: UUID) {
        guard let i = stopwatches.firstIndex(where: { $0.id == id }) else { return }
        stopwatches[i].isRunning.toggle()
    }

    func resetStopwatch(_ id: UUID) {
        guard let i = stopwatches.firstIndex(where: { $0.id == id }) else { return }
        stopwatches[i].elapsedSeconds = 0
        stopwatches[i].isRunning = false
    }

    // MARK: - Interval timer

    func startIntervalTimer() {
        intervalTimer.nextAlarmSeconds = intervalTimer.selectedInterval * 60
        intervalTimer.isRunning = true
    }

    func stopIntervalTimer() {
        intervalTimer.isRunning = false
    }

    func setInterval(_ minutes: Int) {
        intervalTimer.selectedInterval = minutes
        if intervalTimer.isRunning {
            intervalTimer.nextAlarmSeconds = minutes * 60
        }
    }

    private func playAlarm() {
        // Bassoを3連続で鳴らしてアラームらしい音にする
        let path = "/System/Library/Sounds/Basso.aiff"
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.45) {
                NSSound(contentsOfFile: path, byReference: false)?.play()
            }
        }
    }
}
