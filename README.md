# IntervalTimer

常に最前面に表示されるインターバルタイマーアプリ（Mac用）

## 機能
- 現在時刻・経過時間をコンパクトに常時表示
- 5 / 10 / 15 / 20 / 30 / 60分のインターバル設定
- 設定時間ごとに自動でアラーム音（止めなくても次のアラームが鳴る）
- `≡` ボタンで設定パネルを展開/折りたたみ
- 常に最前面・画面右上に初期配置・背景をドラッグで移動可能

## Xcodeプロジェクト作成手順

1. Xcodeを開く
2. `File > New > Project` → `macOS > App` を選択
3. 設定：
   - Product Name: `IntervalTimer`
   - Interface: `SwiftUI`
   - Language: `Swift`
4. 保存先を `interval-timer/` フォルダ内に指定
5. 自動生成された `ContentView.swift` / `IntervalTimerApp.swift` を削除
6. このフォルダの `IntervalTimer/` 内の3つの `.swift` ファイルをプロジェクトに追加（ドラッグ or Add Files）
7. Info.plist に `Application is agent (UIElement)` → `NO`（デフォルトのまま）
8. `⌘R` でビルド・実行

## ファイル構成
```
IntervalTimer/
├── IntervalTimerApp.swift   # アプリエントリ・ウィンドウ設定
├── ContentView.swift        # UI（折りたたみ/展開）
└── TimerManager.swift       # タイマーロジック・アラーム音
```
