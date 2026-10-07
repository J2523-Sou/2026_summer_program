# 2026 summer program

## 開発環境

- macOS
- Xcode 27 以降（Swift toolchain と iOS SDK）
- Visual Studio Code
- VS Code 拡張: SweetPad、Swift（swiftlang.swift-vscode）

## VS Code で開発・起動

1. リポジトリのルートを VS Code で開く。
2. 推奨拡張 SweetPad と Swift をインストールする。
3. SweetPad の Build パネルから scheme `CircleTrackerApp` と実行先を選び、Build and Run する。

プロジェクトと scheme は `sweetpad.toml` と `.vscode/settings.json` に設定済みです。実行先は端末固有の ID を固定せず、SweetPad で利用可能な iOS Simulator または接続済み iPhone を選択してください。ARKit の動作確認には実機を使用してください。

Swift の補完・診断が動かない場合は、SweetPad のコマンドから **Generate Build Server Config** を実行してから、VS Code のウィンドウを再読み込みしてください。`buildServer.json` は端末固有のパスを含むため Git 管理しません。

## コマンドラインからビルド

```sh
sweetpad build
```
