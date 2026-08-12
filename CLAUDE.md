# CLAUDE.md — TextSnap for macOS

> このファイルは、Claude Code向けの開発指示書です。
>
> **開発中のユーザーとの会話、説明、確認、進捗報告は、必ず日本語で行ってください。**
> **GitHubに公開する文章、アプリ内の表示、ソースコード内のコメントは、すべて英語で記述してください。**

---

## 1. 最重要ルール

### 1.1 使用言語

- ユーザーとの会話、Xcodeの操作説明、技術説明、進捗報告：日本語
- アプリのメニュー、ボタン、メッセージ、設定項目：英語
- `README.md`、Issue template、Pull Request template、Release notesなどGitHub上の文章：英語
- コミットメッセージ：英語
- ソースコード内のコメント、ログ：英語
- 変数名、型名、ファイル名：英語

不自然な直訳は避け、一般的で簡潔な英語を使用してください。

### 1.2 開発方針

- 初期版は、画面上の選択範囲をOCRし、結果をクリップボードへコピーする機能だけに集中してください。
- 外部ライブラリやSwift Packageは追加せず、Apple標準フレームワークだけで実装してください。
- 実装を複雑にする機能を独断で追加しないでください。
- macOSの公開APIだけを使用してください。
- OCR画像と認識結果を外部へ送信しないでください。
- OCR画像と認識結果を保存しないでください。

---

## 2. プロジェクト概要

### 2.1 仮称

**TextSnap**

これは作業上の仮称です。GitHub公開前に、既存アプリ、GitHubリポジトリ、Webサービス、商標との明確な競合がないことを確認してください。名称変更が必要な場合は、Bundle Identifier、Xcode Project、Scheme、製品名、READMEをまとめて変更してください。

### 2.2 目的

Windows PowerToys Text Extractorのように、次の操作だけで画面上の文字を取得できる軽量なmacOSメニューバーアプリを作成します。

1. グローバルショートカットを押す。
2. マウスで画面上の範囲を選択する。
3. 選択範囲をローカルでOCRする。
4. 認識結果をプレーンテキストとしてクリップボードへコピーする。

### 2.3 基本要件

- 完全無料で公開する。
- オープンソースとしてGitHubで配布する。
- 日本語と英語を認識する。
- OCRにはApple Vision Frameworkを使用する。
- 画面取得にはScreenCaptureKitを使用する。
- OCR処理はすべてMac上で行う。
- アカウント登録、クラウド通信、テレメトリー、広告、課金は実装しない。
- メニューバーに常駐し、Dockには通常表示しない。

---

## 3. 初期版の機能

### 3.1 基本操作

既定のショートカットは `Command + Shift + 2` とします。

処理の流れは次のとおりです。

```text
Global shortcut
→ Show selection overlays
→ User selects one region
→ Hide all overlays
→ Capture selected region
→ Run OCR
→ Copy plain text to clipboard
→ Play brief feedback sound
```

次の場合は処理をキャンセルしてください。

- `Escape`キーが押された場合
- 右クリックされた場合
- ドラッグせずにクリックだけされた場合
- 選択範囲が実用上小さすぎる場合
- 新しい選択処理を開始する前にアプリが非アクティブになり、選択状態を維持できない場合

キャプチャ処理またはOCR処理中にショートカットが再度押された場合は、二重実行せず、その入力を無視してください。

### 3.2 メニューバー

`NSStatusItem`を使用してメニューバーアイコンを表示します。アイコンはTemplate Imageとして作成し、ライトモードとダークモードの両方に対応させてください。

メニュー項目は次のとおりです。表示はすべて英語にしてください。

```text
Capture Text                  ⌘⇧2
Recognition Language          >
    Auto (Japanese + English)
    English
    Japanese
Language Correction
Play Sound After Copy
Launch at Login
Permission Help
About TextSnap
Quit TextSnap
```

仕様は次のとおりです。

- `Auto (Japanese + English)`を既定値とする。
- 選択された言語、言語補正、サウンド設定を`UserDefaults`へ保存する。
- `Language Correction`は既定でオフにする。
- `Play Sound After Copy`は既定でオンにする。
- 言語選択はメニューバーで行い、範囲選択のたびに別の言語メニューを表示しない。
- 初期版ではショートカット変更画面を実装しない。

### 3.3 言語指定

`Auto`は厳密な言語自動判定ではなく、日本語と英語の両方を認識候補としてVisionへ指定するモードです。

固定文字列を無条件で渡さず、現在のOSでVisionが対応している認識言語を取得し、その中から適切な言語識別子を選択してください。日本語、英語の候補として、OSが返す`ja-JP`、`en-US`などを使用してください。

対応言語が取得できなかった場合はクラッシュさせず、利用可能な言語へフォールバックしてください。

### 3.4 OCR結果の整形

認識結果は、可能な範囲で画面上の読み順に並べてください。

- バウンディングボックスの位置を使用し、上から下へ並べる。
- 同じ行と判断できる結果は左から右へ並べる。
- 行末の空白を削除する。
- テキスト全体の先頭と末尾の空白を削除する。
- 連続する不要な空行だけを整理する。
- 行内の空白は原則として変更しない。
- 句読点の追加、文字の推測置換、URLや識別子の補正を独自に行わない。

初期版では、次を保証対象外とします。

- 日本語の縦書きの正確な読み順
- 表の行列構造の復元
- 複雑な複数段組みの完全な復元
- 手書き文字の正確な認識

### 3.5 完了通知

- 成功時は、設定がオンの場合だけ短いシステムサウンドを再生する。
- 通知センターのバナーは、通常の成功時には使用しない。
- 認識結果が空の場合は、成功時とは異なる短いフィードバックを出す。
- 権限不足やキャプチャ失敗の場合は、原因と対処方法を英語で表示する。

---

## 4. 対応環境と技術構成

### 4.1 対応環境

- Development environment: current stable Xcode
- Language: Swift
- Minimum deployment target: macOS 14.0
- Primary architecture: Apple silicon
- Intel Macについては、使用するAPIとビルド設定で対応可能な場合にUniversal Binaryとして含める。

macOS 14以降に限定し、単一画像取得には`SCScreenshotManager`を使用してください。古い画面取得APIとの二重実装は行わないでください。

### 4.2 標準フレームワーク

- AppKit
- SwiftUI：設定または補助画面が必要な場合だけ使用
- Vision
- ScreenCaptureKit
- ServiceManagement
- Carbon：グローバルショートカット登録部分だけで使用

### 4.3 外部依存

外部パッケージは使用しないでください。

Swift Package Manager、CocoaPods、その他の外部ライブラリを追加する前に、Apple標準APIで実現できないことを確認してください。初期版では追加を認めません。

---

## 5. 推奨ファイル構成

```text
TextSnap/
├── TextSnapApp.swift
├── AppDelegate.swift
├── StatusBarController.swift
├── HotKeyManager.swift
├── CaptureCoordinator.swift
├── SelectionOverlayController.swift
├── SelectionOverlayWindow.swift
├── SelectionOverlayView.swift
├── ScreenCaptureService.swift
├── CoordinateConverter.swift
├── OCRService.swift
├── OCRTextLayoutService.swift
├── ClipboardService.swift
├── PermissionService.swift
├── LoginItemService.swift
├── Preferences.swift
├── AppError.swift
├── Assets.xcassets
├── Info.plist
└── TextSnap.entitlements

TextSnapTests/
├── CoordinateConverterTests.swift
├── OCRTextLayoutServiceTests.swift
└── PreferencesTests.swift
```

責務を分離し、画面取得、座標変換、OCR、読み順処理、クリップボード操作を1つのクラスにまとめないでください。

---

## 6. 実装仕様

### 6.1 アプリライフサイクル

- XcodeのmacOS Appテンプレートを使用する。
- SwiftUI App lifecycleを使用し、`@NSApplicationDelegateAdaptor`で`AppDelegate`を接続する。
- 通常のアプリウィンドウは起動時に表示しない。
- メニューバー、オーバーレイ、必要な補助画面はAppKitで実装する。
- `Info.plist`の`LSUIElement`を`YES`にし、通常はDockへ表示しない。

### 6.2 グローバルショートカット

Carbonの`RegisterEventHotKey`を使用してください。

- Carbon依存コードは`HotKeyManager`内だけに置く。
- 登録成功と登録失敗を判定する。
- 他のアプリとの競合で登録できない場合は、英語のエラーを表示する。
- アプリ終了時に登録を解除する。
- 初期版ではユーザーによるキー変更を実装しない。
- 将来別の実装へ交換できるよう、他のアプリ機能から分離する。

### 6.3 選択オーバーレイ

ディスプレイごとに1つのボーダーレスウィンドウを作成してください。すべてのディスプレイを覆う巨大な1枚のウィンドウにはしないでください。

- `NSScreen.screens`ごとにオーバーレイを表示する。
- 異なるRetina倍率を持つディスプレイに対応する。
- 左、右、上に配置された外部ディスプレイの負座標または非標準座標に対応する。
- ドラッグ開始地点が属するディスプレイ内だけで選択を完了する。
- 初期版では複数ディスプレイをまたぐ選択を非対応とする。
- 選択外を半透明の黒で覆い、選択中の矩形を見やすく表示する。
- 選択矩形には細い枠線を表示する。
- `Escape`または右クリックで全オーバーレイを閉じる。

### 6.4 画面取得

ScreenCaptureKitを使用し、単一画像取得は`SCScreenshotManager`で実装してください。

- `SCShareableContent`から対象ディスプレイを特定する。
- 選択された`NSScreen`と対応する`SCDisplay`を安定して関連付ける。
- `SCContentFilter`で対象ディスプレイを指定する。
- 自分のアプリまたはオーバーレイをキャプチャ対象から除外する。
- オーバーレイを閉じた後、画面更新が反映されてから画像を取得する。
- 不要なストリーミングキャプチャは開始しない。
- `CGWindowListCreateImage`などの旧APIをフォールバックとして追加しない。

### 6.5 座標変換

座標変換は最も誤りが起きやすいため、`CoordinateConverter`へ集約してください。

- 選択矩形は、選択された`NSScreen`のローカル座標として保持する。
- `NSScreen.main`を座標変換の基準に使用しない。
- 選択された画面の`backingScaleFactor`を使用し、ポイントからピクセルへ変換する。
- AppKit座標、Core Graphics座標、ScreenCaptureKit座標、Vision正規化座標を別々の変換関数で扱う。
- Y軸方向の違いを明示的に処理する。
- 変換後の矩形を対象画像の境界内に収める。
- 左側、右側、上側に配置されたディスプレイを単体テストと実機試験の両方で確認する。

### 6.6 OCR

`VNRecognizeTextRequest`を使用してください。

- `recognitionLevel = .accurate`
- 選択された認識言語だけを`recognitionLanguages`へ設定する。
- `usesLanguageCorrection`はユーザー設定に従い、既定は`false`とする。
- OCRはバックグラウンドで実行し、UIを停止させない。
- OCR結果はバウンディングボックス情報とともに取得する。
- 読み順の調整は`OCRTextLayoutService`で行う。
- 認識結果が空でもエラーとしてクラッシュさせない。
- 画像や結果をファイルへ保存しない。
- 外部サービスへ送信しない。

### 6.7 クリップボード

`NSPasteboard.general`を使用してください。

- OCRが成功し、空ではない場合だけ既存内容をクリアする。
- プレーンテキストとして書き込む。
- クリップボードへの書き込みに失敗した場合は、英語のエラーを表示する。

### 6.8 画面収録権限

- 起動直後には不要な権限要求を表示しない。
- 最初のキャプチャ操作時に権限を確認する。
- 必要な場合は画面収録権限を要求する。
- 拒否または未許可の場合は、英語の説明と`Open System Settings`ボタンを表示する。
- 権限付与後に再起動が必要な場合は、英語で明確に案内する。
- `Info.plist`へ画面収録の使用目的を英語で記載する。

使用目的の文言は次を基本とします。

```text
TextSnap needs Screen Recording access to capture the area you select and recognize its text locally on your Mac.
```

### 6.9 ログイン時起動

macOS 13以降の`ServiceManagement`と`SMAppService.mainApp`を使用してください。

- 古いLogin Item方式は使用しない。
- メニューのチェック状態と実際の登録状態を同期する。
- 登録または解除に失敗した場合は、英語のエラーを表示する。

---

## 7. Xcodeセットアップ

### 7.1 前提

ユーザーは**Kohei Ishikawa**名義でApple Developer Programへ加入済みです。

Apple Developer Programに加入していない前提の説明、無料Apple IDだけを使用する前提、未署名配布を標準とする説明は使用しないでください。

### 7.2 プロジェクト作成

1. Xcodeを起動する。
2. `File > New > Project`を開く。
3. `macOS > App`を選択する。
4. 次の設定で作成する。

```text
Product Name: TextSnap
Team: Kohei Ishikawa's Apple Developer team
Organization Identifier: use the identifier specified by Kohei Ishikawa
Interface: SwiftUI
Language: Swift
Testing System: Swift Testing or XCTest
Storage: None
```

Organization IdentifierとBundle Identifierは、ユーザーが所有し、Apple Developer portalで管理できる値を使用してください。仮の識別子を無断で確定しないでください。

5. SwiftUI App lifecycleで作成する。
6. `@NSApplicationDelegateAdaptor`を追加し、AppKitベースの常駐処理へ接続する。
7. `LSUIElement = YES`を設定する。
8. Deployment TargetをmacOS 14.0に設定する。

### 7.3 Signing & Capabilities

- `Automatically manage signing`を有効にする。
- TeamはKohei Ishikawaが利用できるDeveloper Teamを選択する。
- 配布用はDeveloper ID Application証明書を使用する。
- App Sandbox、コード署名、Notarization、Screen Recording権限を別の仕組みとして扱う。
- 初期版は、実装と配布試験を簡潔にするためApp Sandboxを無効としてよい。
- Sandboxを無効にしても、画面収録権限は必要である。
- Hardened Runtimeを有効にする。
- 不要なentitlementを追加しない。

App Sandboxを無効にする理由を「署名なしだから」と説明しないでください。

### 7.4 ローカル動作確認

1. XcodeからDebugビルドを実行する。
2. メニューバーにアイコンが表示されることを確認する。
3. Dockへ通常表示されないことを確認する。
4. キャプチャ操作を実行する。
5. 画面収録権限を付与する。
6. 必要に応じてアプリを再起動する。
7. 日本語、英語、日英混在の文字を取得する。
8. `Command + V`で認識結果を確認する。

---

## 8. ビルド、署名、公証、配布

### 8.1 配布方針

GitHub Releasesで無料配布します。Apple Developer Program加入済みのため、標準の配布物はDeveloper IDで署名し、AppleへNotarizationを申請し、Staplingまで完了させてください。

未署名アプリまたは未公証アプリを標準配布物にしないでください。

### 8.2 Releaseビルド

- Release構成でArchiveを作成する。
- Developer ID Applicationで署名する。
- Hardened Runtimeを有効にする。
- Archiveから配布用の`.app`をExportする。
- `codesign`で署名状態を確認する。
- `spctl`でGatekeeper評価を確認する。

### 8.3 Notarization

`notarytool`を使用してください。`altool`は使用しないでください。

認証情報はソースコード、設定ファイル、Git履歴へ保存せず、macOS Keychainへ保存してください。

処理の概略は次のとおりです。

```bash
ditto -c -k --sequesterRsrc --keepParent TextSnap.app TextSnap-notarization.zip
xcrun notarytool submit TextSnap-notarization.zip --keychain-profile "TextSnap-Notary" --wait
xcrun stapler staple TextSnap.app
xcrun stapler validate TextSnap.app
codesign --verify --deep --strict --verbose=2 TextSnap.app
spctl --assess --type execute --verbose=4 TextSnap.app
```

実際のKeychain profile名、Team ID、証明書名は、Kohei IshikawaのApple Developer環境で確認した値を使用してください。秘密情報や個人情報をリポジトリへ書かないでください。

### 8.4 GitHub Release用ZIP

公証とStaplingが完了した`.app`から配布用ZIPを作成してください。

```bash
ditto -c -k --sequesterRsrc --keepParent TextSnap.app TextSnap.zip
```

ZIPを展開したアプリについて、別のmacOSユーザー環境を想定した最終確認を行ってください。

### 8.5 バージョン管理

- Marketing VersionはSemantic Versioningを基本とする。
- 初回リリースは`1.0.0`とする。
- Build Numberはリリースごとに増加させる。
- Git tagは`v1.0.0`形式とする。
- GitHub Releaseのタイトル、本文は英語で記述する。

---

## 9. GitHubリポジトリ

### 9.1 公開設定

- Repository name: `TextSnap`。名称確定後に変更してよい。
- Visibility: Public
- License: MIT License
- GitHub上の文章はすべて英語
- リポジトリに実行バイナリを直接コミットしない。
- 配布用ZIPはGitHub Releasesへ添付する。

### 9.2 必須ファイル

```text
README.md
LICENSE
CONTRIBUTING.md
SECURITY.md
CHANGELOG.md
.gitignore
.github/ISSUE_TEMPLATE/
.github/pull_request_template.md
CLAUDE.md
```

`README.md`には次を英語で記載してください。

- Overview
- Features
- Privacy
- Requirements
- Installation
- Screen Recording permission
- Usage
- Recognition languages
- Build from source
- Signed and notarized release information
- Troubleshooting
- License

プライバシーについて、次を明記してください。

```text
TextSnap processes screenshots and recognized text locally on your Mac. It does not upload, store, or transmit captured images or OCR results.
```

### 9.3 `.gitignore`

Xcodeの生成物、ユーザー固有設定、署名関連情報、認証情報を追跡しないでください。

```gitignore
.DS_Store
build/
DerivedData/
*.xcuserstate
xcuserdata/
*.xccheckout
*.xcscmblueprint
*.ipa
*.dSYM.zip
*.dSYM
*.p12
*.cer
*.mobileprovision
*.provisionprofile
.env
.env.*
```

共有が必要なXcode project、workspace、schemeは除外しないでください。

### 9.4 CommitとPush

- 意味のある単位でローカルcommitを行ってよい。
- コミットメッセージは英語で書く。
- push前に`git status`と追跡対象を確認する。
- 秘密情報、証明書、署名ファイル、個人用Xcode設定を含めない。
- 正しいremoteが設定済みで、認証済みの場合は、ユーザーの追加指示を待たずにpushしてよい。
- remoteがない場合は、GitHub CLIを使用してpublicリポジトリを作成する。
- 既存の別リポジトリを変更しない。
- 強制pushを行わない。
- 既存タグを上書きしない。
- 履歴を書き換えない。
- `main`ブランチが保護されている場合は、作業ブランチとPull Requestを使用する。

推奨コミット例：

```text
Create menu bar application shell
Add global capture shortcut
Implement per-display selection overlays
Add ScreenCaptureKit screenshot service
Implement local Japanese and English OCR
Add signed and notarized release workflow
```

---

## 10. テスト

### 10.1 単体テスト

少なくとも次をテストしてください。

- ポイントからピクセルへの座標変換
- Y軸反転
- 負座標を持つ外部ディスプレイ
- 画像境界からはみ出した矩形の補正
- OCR結果の上から下、左から右への並べ替え
- 空のOCR結果
- 設定値の保存と復元

### 10.2 OCR実機試験

- 日本語のみ
- 英語のみ
- 日本語と英語の混在
- 数字と記号
- URL
- メールアドレス
- Case Numberや製品コード
- XMLまたはソースコード
- 小さい文字
- 白地に黒文字
- 黒地に白文字
- OCR対象が存在しない範囲

### 10.3 画面環境試験

- Mac内蔵Retinaディスプレイ
- 外部ディスプレイ
- 異なる拡大率の複数ディスプレイ
- 外部ディスプレイを主画面の左に配置
- 外部ディスプレイを主画面の右に配置
- 外部ディスプレイを主画面の上に配置
- ダークモード
- 複数Spaces
- フルスクリーンアプリ

### 10.4 操作試験

- ショートカットから起動
- メニューから起動
- `Escape`でキャンセル
- 右クリックでキャンセル
- 小さすぎる選択範囲
- 画面収録権限を拒否
- 権限付与後の再実行
- ホットキー競合
- OCR処理中の再実行
- ログイン時起動の登録と解除
- アプリ終了後のホットキー解除

### 10.5 配布試験

- ReleaseアプリがDeveloper IDで正しく署名されている。
- Notarizationが承認されている。
- Staplingが成功している。
- `codesign`検証が成功する。
- `spctl`評価が成功する。
- GitHub ReleaseのZIPを再取得して展開できる。
- 初回起動時に予期しないGatekeeper警告が出ない。
- 画面収録権限の案内が正しく表示される。

---

## 11. エラー処理

エラーは`AppError`へ集約し、利用者向けメッセージは簡潔な英語で表示してください。

最低限、次を区別してください。

- Screen Recording permission unavailable
- Screen capture failed
- Display mapping failed
- OCR failed
- No text found
- Clipboard write failed
- Global shortcut registration failed
- Login item update failed

デバッグ情報には技術的な詳細を含めて構いませんが、OCRした文字列や画面画像をログへ出力しないでください。

---

## 12. スコープ外

初期版では、次を実装しないでください。

- OCR履歴
- 画像履歴
- OCR結果の編集画面
- 翻訳
- クラウドOCR
- アカウント登録
- テレメトリー
- 自動アップデート
- 課金
- スクリーンショット編集
- 注釈
- 画面録画
- 表の構造化出力
- 縦書きへの特別対応
- 複数ディスプレイをまたぐ範囲選択
- ショートカットのカスタマイズ画面

新機能を追加する場合も、最初の目的である「範囲選択OCRからクリップボードへのコピー」を損なわないでください。

---

## 13. 完了条件

初期版は、次の条件をすべて満たした場合に完了とします。

- メニューバーから常駐できる。
- Dockへ通常表示されない。
- `Command + Shift + 2`で範囲選択を開始できる。
- 選択範囲だけを正しくキャプチャできる。
- オーバーレイが取得画像へ写り込まない。
- 日本語、英語、日英混在をローカルでOCRできる。
- OCR結果をプレーンテキストとしてクリップボードへコピーできる。
- 複数ディスプレイとRetina倍率で座標が正しい。
- 権限不足時に利用者へ適切な案内を表示できる。
- Developer IDで署名されている。
- AppleのNotarizationが完了している。
- StaplingとGatekeeper検証が成功している。
- GitHub上の文章とアプリ内UIがすべて英語である。
- 開発中のユーザーとのやりとりが日本語である。

---

## 14. Claude Codeへの最終指示

- ユーザーへの説明は必ず日本語で行ってください。
- GitHubに保存する文章、UI、コードコメントは英語にしてください。
- 実装前に既存ファイルを確認し、不要な全面書き換えを避けてください。
- 変更後はビルドと関連テストを実行してください。
- コンパイルエラーやテスト失敗を残したまま完了としないでください。
- 画面画像、OCR結果、Apple認証情報、証明書、秘密鍵をGitへ追加しないでください。
- ローカルcommitは適切な単位で行ってください。
- push可能な既存remoteがある場合は、安全確認後にpushしてください。
- GitHub公開物はKohei IshikawaのApple Developer Program加入を前提として、Developer ID署名とNotarizationを行ってください。
