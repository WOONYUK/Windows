# イベントログ自動取得スクリプト（前日分を取得）
# 対応OS：Windows Server 2012以降

# 取得対象のイベントログとして「システム」と「アプリケーション」を指定する
$lognames = @("System","Application","Security")

#フォルダを指定必要な文字列
$year = (Get-Date).AddDays(-1).ToString("yyyy")
$month = (Get-Date).AddDays(-1).ToString("MM")
$day = (Get-Date).AddDays(-1).ToString("dd")

# 先月時点のyyyyMM文字列を取得
$yyyyMMdd = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

# 出力先として「C:\Backup\year\month\day」フォルダを指定・作成する。
$dstFolder = ("C:\Backup\" + $year + "\" + $month + "\" + $day)
if((Test-Path $dstFolder) -eq $False){New-Item $dstFolder -ItemType Directory}

# イベントログを取得する対象の期間を指定する（先日から末日までを指定）
$startJTime =(Get-Date).AddDays(-1).ToString("yyyy年MM月dd日00時00分00秒")
$endJTime = (Get-Date).ToString("yyyy年MM月dd日00時00分00秒")
$startUtcTime = [System.TimeZoneInfo]::ConvertTimeToUtc($startJTime).ToString("yyyy-MM-ddTHH:mm:ssZ")
$endUtcTime = [System.TimeZoneInfo]::ConvertTimeToUtc($endJTime).ToString("yyyy-MM-ddTHH:mm:ssZ")


$filter = @"
  Event/System/TimeCreated[@SystemTime>='$startUtcTime'] and
  Event/System/TimeCreated[@SystemTime<'$endUtcTime']
"@ 

# イベントログ出力用のオブジェクトを作成
$evsession = New-Object -TypeName System.Diagnostics.Eventing.Reader.EventLogSession

# イベントログをevtx形式で出力する（「LocaleMetaData」も日本語の表示情報で出力させる）
foreach($logname in $lognames){
  $outfile = $dstFolder + "\" + $logname + "_" + $yyyyMMdd + ".evtx"
  $locale = [System.Globalization.CultureInfo]::CreateSpecificCulture("ja-JP")
  $evsession.ExportLogAndMessages($logname,"LogName",$filter,$outfile,$True,$locale)
}

#ログ取得に成功したか失敗したかのEventLog
if ($? -eq $true) {
  Write-Output "Log取得を成功しました。"
  Write-EventLog -LogName Application -EntryType Information -Source BackupLog -EventId 0 -Message "Log取得を成功しました。"
} else {
  Write-Output "Log取得を失敗しました。"
  Write-EventLog -LogName Application -EntryType Error -Source BackupLog -EventId 1 -Message "Log取得を失敗しました。"
}
