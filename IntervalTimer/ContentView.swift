import SwiftUI

struct ContentView: View {
    @StateObject private var state = AppState()
    @State private var isExpanded = false
    @State private var now = Date()

    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            collapsedView

            if isExpanded {
                divider
                expandedPanel
                    .transition(.opacity)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .fixedSize()
        .onReceive(clockTimer) { t in now = t }
    }

    // MARK: - 通常表示（時刻なし・数値のみ）

    private var collapsedView: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                // ストップウォッチ（最大3つ）
                ForEach(state.stopwatches) { sw in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(sw.isRunning ? Color.green : Color.white.opacity(0.22))
                            .frame(width: 5, height: 5)
                        Text(sw.formatted)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                // タイマー（1つ）
                HStack(spacing: 6) {
                    Text("T")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.orange.opacity(0.75))
                        .frame(width: 7, alignment: .center)
                    Text(state.intervalTimer.isRunning
                         ? state.intervalTimer.nextAlarmFormatted
                         : "\(state.intervalTimer.selectedInterval)m")
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundStyle(state.intervalTimer.isRunning ? .orange : .white.opacity(0.28))
                }
            }

            // 展開ボタン（chevronでパネルの開閉を示す）
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }

    // MARK: - 展開パネル

    private var expandedPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 現在時刻（展開時のみ表示）
            Text(now, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute().second())
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
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
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(width: 72, alignment: .leading)

                        // 再生/停止
                        Button { state.toggleStopwatch(sw.id) } label: {
                            Image(systemName: sw.isRunning ? "stop.fill" : "play.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(sw.isRunning ? Color.red.opacity(0.85) : Color.green.opacity(0.85))
                        }
                        .buttonStyle(.plain)

                        // 削除
                        Button { state.removeStopwatch(sw.id) } label: {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // SW追加（3つ未満のとき）
                if state.stopwatches.count < 3 {
                    Button { state.addStopwatch() } label: {
                        Label("SW追加", systemImage: "plus")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            divider

            // インターバルタイマー操作
            VStack(alignment: .leading, spacing: 6) {
                // インターバル選択
                HStack(spacing: 3) {
                    ForEach(state.intervals, id: \.self) { min in
                        let selected = state.intervalTimer.selectedInterval == min
                        Button { state.setInterval(min) } label: {
                            Text(min == 60 ? "1h" : "\(min)m")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(selected ? Color.black : Color.white.opacity(0.6))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(selected ? Color.white : Color.white.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 再生/停止 + 次のアラームまでの時間
                HStack(spacing: 8) {
                    Button {
                        state.intervalTimer.isRunning ? state.stopIntervalTimer() : state.startIntervalTimer()
                    } label: {
                        Image(systemName: state.intervalTimer.isRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(state.intervalTimer.isRunning ? Color.red.opacity(0.85) : Color.green.opacity(0.85))
                    }
                    .buttonStyle(.plain)

                    if state.intervalTimer.isRunning {
                        Text("next \(state.intervalTimer.nextAlarmFormatted)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.orange.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.09))
            .frame(height: 0.5)
    }
}
