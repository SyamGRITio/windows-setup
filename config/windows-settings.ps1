#Requires -Version 7
$ErrorActionPreference = 'Stop'

############################## エクスプローラー ##############################
$adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

Set-ItemProperty $adv -Name HideFileExt        -Value 0   # 拡張子を表示
Set-ItemProperty $adv -Name Hidden             -Value 1   # 隠しファイルを表示
Set-ItemProperty $adv -Name AutoCheckSelect    -Value 1   # 項目チェックボックス

############################## タスクバー ##############################
Set-ItemProperty $adv -Name TaskbarAl          -Value 0   # 左寄せ
Set-ItemProperty $adv -Name ShowTaskViewButton -Value 0   # タスクビュー
Set-ItemProperty $adv -Name TaskbarDa          -Value 0   # ウィジェット
Set-ItemProperty $adv -Name TaskbarMn          -Value 0   # チャット

$search = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
Set-ItemProperty $search -Name SearchboxTaskbarMode -Value 0   # 検索ボックス

############################## ダークモード ##############################
$theme = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'

Set-ItemProperty $theme -Name AppsUseLightTheme    -Value 0
Set-ItemProperty $theme -Name SystemUsesLightTheme -Value 0

############################## 背景を単色黒 ##############################
Add-Type @'
using System.Runtime.InteropServices;
public class Wp {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@

Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value ''
Set-ItemProperty 'HKCU:\Control Panel\Colors'  -Name Background -Value '0 0 0'

# SPI_SETDESKWALLPAPER=20, SPIF_UPDATEINIFILE|SPIF_SENDCHANGE=3
# 壁紙の変更をシステムに通知する
# 20 = SPI_SETDESKWALLPAPER（壁紙を設定）
#  3 = SPIF_UPDATEINIFILE | SPIF_SENDCHANGE（保存して他アプリにも通知）
[Wp]::SystemParametersInfo(20, 0, '', 3) | Out-Null

############################## 反映 ##############################
Stop-Process -Name explorer -Force