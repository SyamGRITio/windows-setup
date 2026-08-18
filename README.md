# windows-setup
新しいWindows環境を短時間で立ち上げるためのセットアップキット。

現場が変わるたびに同じ設定を思い出しながら手で入れていたので、コード化して持ち運べるようにした。

## 構成
```
bootstrap.ps1                    まとめて適用する
config/
├── setup.core.winget            どの現場でも入れるもの
├── setup.optional.winget        現場によって選ぶもの
├── profile.ps1                  PowerShellプロファイル（公開）
├── profile.local.ps1            現場固有の設定（gitignore対象）
├── terminal-fragment.json       Windows Terminal の見た目
└── windows-settings.ps1         エクスプローラー・タスクバー・テーマ・壁紙（単色黒）
scripts/
└── restart-explorer.bat         エクスプローラー再起動
```

## 前提
- Windows 10 1809 以降 / Windows 11
- winget（アプリ インストーラー）が使えること
- PowerShell 7

## 使い方

最小構成だけ入れる。

```powershell
git clone https://github.com/SyamGRITio/windows-setup.git
cd windows-setup
.\bootstrap.ps1
```

現場で必要なものも入れる場合。

```powershell
.\bootstrap.ps1 -IncludeOptional
```

適用内容を先に見たいとき。

```powershell
winget configure show -f .\config\setup.core.winget
```

## 一部だけ入れたいとき

optional をまるごと入れず、個別に選ぶ場合。

```powershell
winget install --id Kubernetes.kubectl --exact
```

`--exact` は ID の完全一致を要求する。付けないと部分一致で別のパッケージが入ることがある。

ID の一覧は `config/setup.optional.winget` を参照。

## winget が使えない現場

グループポリシーで無効化されている、Microsoft Store が塞がれている、管理者権限がない、といったケースがある。

その場合は scoop を検討する。ユーザーフォルダ配下にインストールされるため、管理者権限が不要。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

ただし、現場によっては scoop 自体が認可対象外のことがある。chocolatey しか承認されていない環境もあるため、使えるものを先に確認する。

どの管理ツールも使えない場合は、`config/setup.*.winget` を必要なツールの一覧として、申請にそのまま使う。

## PowerShell プロファイルについて

`$PROFILE` はターミナルごとに別のファイルを指す。Windows Terminal と VS Code で設定が分かれてしまうため、全ホスト共通のファイルから読み込む。

```powershell
Set-Content $PROFILE.CurrentUserAllHosts -Value '. "<このリポジトリのパス>\config\profile.ps1"' -Encoding utf8
```

`profile.ps1` は末尾で `profile.local.ps1` を探して、あれば読み込む。無い場合は何も起きない。

現場固有の設定（アカウント ID、プロファイル名、言語のバージョン固定など）はすべて `profile.local.ps1` に書く。このファイルは gitignore 対象なので公開されない。

認証情報そのものはプロファイルに書かない。AWS は `~/.aws/credentials`、Azure は `az login` のキャッシュに任せ、プロファイルにはプロファイル名だけを置く。

## Windows Terminal の設定

`settings.json` は Terminal 自身が起動時に書き換えるため、丸ごと置き換えると壊れる。

フラグメントとして別ファイルで重ねる。

```powershell
$dir = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\syam"
New-Item -ItemType Directory -Path $dir -Force
Copy-Item .\config\terminal-fragment.json "$dir\settings.json" -Force
```

## Windows の個人設定

`config/windows-settings.ps1` で、エクスプローラーの拡張子表示、タスクバーの左寄せ、ダークモード、背景の単色黒などをまとめて適用する。

書き換えるのは HKCU（現在のユーザー）のみ。GUI の設定画面と同じ場所を触るだけだが、EDR が入っている環境ではスクリプトからのレジストリ操作が検知される可能性がある。現場で警告が出たら手動設定に切り替える。

実行するとエクスプローラーが再起動する。作業中のウィンドウは閉じておく。

## エクスプローラーの再起動

不具合が出たときの復旧用。

- ターミナルから: `re`
- デスクトップの `restart-explorer.bat` をダブルクリック

ターミナルが開けない状態も想定して両方置いている。

## ライセンス

MIT