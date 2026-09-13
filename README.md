# 2026 summer program

## 開発環境

- macOS
- Xcode 27 以降

## 起動

1. `circle_tracker/CircleTrackerApp.xcodeproj` をXcodeで開く。
2. 実行先にiPhoneシミュレータを選択する。
3. `⌘R` でビルド・起動する。

## コマンドラインからビルド

```sh
xcodebuild -project circle_tracker/CircleTrackerApp.xcodeproj \
  -scheme CircleTrackerApp \
  -sdk iphonesimulator \
  -configuration Debug build
```
