import Foundation
import AppKit

class TimerManager: ObservableObject {
    @Published var elapsedSeconds: Int = 0
    @Published var nextAlarmSeconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var selectedInterval: Int = 5

    let intervals = [5, 10, 15, 20, 30, 60]

    private var ticker: Timer?

    func start() {
        elapsedSeconds = 0
        nextAlarmSeconds = selectedInterval * 60
        isRunning = true

        ticker = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            self.nextAlarmSeconds -= 1

            if self.nextAlarmSeconds <= 0 {
                self.playAlarm()
                self.nextAlarmSeconds = self.selectedInterval * 60
            }
        }
        RunLoop.main.add(ticker!, forMode: .common)
    }

    func stop() {
        ticker?.invalidate()
        ticker = nil
        isRunning = false
    }

    func setInterval(_ minutes: Int) {
        selectedInterval = minutes
        if isRunning {
            nextAlarmSeconds = minutes * 60
        }
    }

    private func playAlarm() {
        // "Funk"を8回・0.35秒間隔で繰り返して鳴らす（けたたましいアラーム）
        let repeatCount = 8
        let interval = 0.35
        for i in 0..<repeatCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                if let sound = NSSound(named: NSSound.Name("Funk")) {
                    sound.play()
                } else {
                    NSSound.beep()
                }
            }
        }
    }

    var elapsedFormatted: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var nextAlarmFormatted: String {
        let m = nextAlarmSeconds / 60
        let s = nextAlarmSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
