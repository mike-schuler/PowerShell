#Script to monitor log files for specific strings
#Author: Mike Schuler
#Date: 11/18/22

#Set the path to the log file
$LogPath = "test.log"

#Set the string to search for
$SearchString = "test"

#Set the number of lines to read from the log file
$LinesToRead = 100

#Set the number of seconds to wait between checks
$WaitTime = 10


#Read the log file
$Log = Get-Content $LogPath -Tail $LinesToRead

#Search the log file for the string
$logResult = $Log | Select-String $SearchString
if($logResult -ne $null)
{
    Write-Host Error found in log file
}

#Wait for the specified number of seconds
Start-Sleep -Seconds $WaitTime

#Loop back to the beginning
Continue
