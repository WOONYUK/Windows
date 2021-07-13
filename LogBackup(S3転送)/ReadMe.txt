1.事前に以下のコマンドでイベントを登録する。
##LogBackUp実行結果
＞New-EventLog -LogName Application -Source BackupLog

##S3転送実行結果
＞New-EventLog -LogName Application -Source ExportLogToS3