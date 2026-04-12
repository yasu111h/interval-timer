import SwiftUI

struct ContentView: View {
    @StateObject private var manager = TimerManager()
    @State private var isExpanded = false
    @State private var now = Date()

    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            mainRow
            if isExpanded {
                expandedPanel
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .fixedSize()
        .onReceive(clockTimer) { t in now = t }
    }

    // MARK: - メイン行

    private var mainRow: some View {
        HStack(spacing: 10) {
            // 現在時刻
            Text(now, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute().second())
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.85))

            Divider()
                .frame(height: 12)
                .background(Color.white.opacity(0.2))

            // 経過時間
            Text(manager.elapsedFormatted)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(manager.isRunning ? Color.green : Color.white.opacity(0.35))

            // 展開ボタン
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "xmark" : "slider.horizontal.3")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
    }

    // MARK: - 展開パネル

    private var expandedPanel: some View {
        VStack(spacing: 7) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5)

            // インターバル選択
            HStack(spacing: 4) {
                ForEach(manager.intervals, id: \.self) { min in
                    let selected = manager.selectedInterval == min
                    Button {
                        manager.setInterval(min)
                    } label: {
                        Text(min == 60 ? "1h" : "\(min)m")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(selected ? Color.black : Color.white.opacity(0.75))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(selected ? Color.white : Color.white.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // 操作行
            HStack(spacing: 10) {
                // スタート / ストップ
                Button {
                    manager.isRunning ? manager.stop() : manager.start()
                } label: {
                    Image(systemName: manager.isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(manager.isRunning ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)

                if manager.isRunning {
                    Text("next \(manager.nextAlarmFormatted)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.orange.opacity(0.85))
                }

                Spacer()
            }
            .padding(.horizontal, 2)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

#Preview {
    ContentView()
        .frame(width: 260)
}
