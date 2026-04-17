import SwiftUI

private struct HeightPref: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct ContentView: View {
    @StateObject private var state = AppState()
    @State private var isExpanded = false
    @State private var now = Date()
    @State private var prevHeight: CGFloat = 0

    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            collapsedView
            // 展開パネルは下に表示、ウィンドウが上方向に伸びるため常時表示部が上にスライド
            if isExpanded {
                divider
                expandedPanel
                    .transition(.opacity)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.88))
        )
        // ダークモードで視認しやすい枠線＋グロー
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.40), lineWidth: 1.0)
        )
        .shadow(color: .white.opacity(0.08), radius: 6)
        .fixedSize()
        // 上方向展開のためウィンドウ高さ変化を検知して位置補正
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: HeightPref.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(HeightPref.self) { newH in
            let delta = newH - prevHeight
            let oldH = prevHeight
            prevHeight = newH
            guard oldH > 0, abs(delta) > 1 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                guard let w = NSApplication.shared.windows.first else { return }
                let f = w.frame
                // 下端を固定したまま上に伸ばす
                w.setFrameOrigin(NSPoint(x: f.origin.x, y: f.origin.y + delta))
            }
        }
        .onReceive(clockTimer) { t in now = t }
    }

    // MARK: - 通常表示

    private var collapsedView: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                // ストップウォッチ
                ForEach(state.stopwatches) { sw in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(sw.isRunning ? Color.green : Color.white.opacity(0.4))
                            .frame(width: 5, height: 5)
                        Text(sw.formatted)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.9))
                        Button { state.toggleStopwatch(sw.id) } label: {
                            Image(systemName: sw.isRunning ? "stop.fill" : "play.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(sw.isRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // タイマー：インターバル＋残り時間
                HStack(spacing: 5) {
                    Text("T")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.orange)
                        .frame(width: 7, alignment: .center)
                    if state.intervalTimer.isRunning {
                        Text(state.intervalTimer.nextAlarmFormatted)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(state.intervalTimer.selectedInterval)m")
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Button {
                        state.intervalTimer.isRunning ? state.stopIntervalTimer() : state.startIntervalTimer()
                    } label: {
                        Image(systemName: state.intervalTimer.isRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(state.intervalTimer.isRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                }
            }

            // 展開ボタン
            Button {
                withAnimation(.easeInOut(duration: .init(0.15))) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.15))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }

    // MARK: - 展開パネル

    private var expandedPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 現在時刻（秒なし・ラベル付き）
            HStack(spacing: 5) {
                Text("時刻")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.45))
                Text(now, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute())
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)

            divider

            // ストップウォッチ操作
            VStack(alignment: .leading, spacing: 5) {
                ForEach(state.stopwatches) { sw in
                    HStack(spacing: 8) {
                        Text(sw.formatted)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(width: 72, alignment: .leading)

                        Button { state.toggleStopwatch(sw.id) } label: {
                            Image(systemName: sw.isRunning ? "stop.fill" : "play.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(sw.isRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                        }
                        .buttonStyle(.plain)

                        Button { state.resetStopwatch(sw.id) } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .buttonStyle(.plain)

                        Button { state.removeStopwatch(sw.id) } label: {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // SW追加ボタン（ボタンらしいスタイル）
                if state.stopwatches.count < 3 {
                    Button { state.addStopwatch() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .medium))
                            Text("SW追加")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.14))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            divider

            // インターバルタイマー操作
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(state.intervals, id: \.self) { min in
                        let selected = state.intervalTimer.selectedInterval == min
                        Button { state.setInterval(min) } label: {
                            Text(min == 60 ? "1h" : "\(min)m")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(selected ? Color.black : Color.white.opacity(0.8))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(selected ? Color.white : Color.white.opacity(0.14))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.10))
            .frame(height: 0.5)
    }
}
