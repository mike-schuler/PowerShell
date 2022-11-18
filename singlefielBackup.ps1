$fileToBackup = "C:\Users\mschuler\Desktop\laser\test.txt"
$backupPath = "C:\Users\mschuler\Desktop\laser"
$backupFile = $backupPath + "\" + (Get-Date -Format "yyyy-MM-dd") + "_" + (Get-Date -Format "HH-mm-ss") + ".txt"

#copy file to backup folder
Copy-Item $fileToBackup $backupFile

#delete files older than 30 days
Get-ChildItem $backupPath -Filter *.txt -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force

