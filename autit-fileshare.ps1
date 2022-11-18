#Script to automate manual process of reviewing file share permissions
#Author: Michael Schuler
#Date: 10/28/2022
#Version: 1.0

#Set variables
$sharePath = "C:\Users\mschuler\Desktop\laser"

#regex to matc phone numbers
$regex = "^\d{3}-\d{3}-\d{4}$"
#regex to match email addresses
$regex2 = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
#regex to match street addresses
$regex3 = "^[0-9]+ [a-zA-Z]+ [a-zA-Z]+$"
#regex to match dates
$regex4 = "^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$"
function Get-PathPermissions {
 
    param ( [Parameter(Mandatory=$true)] [System.String]${Path} )
     
        begin {
        $root = Get-Item $Path
        ($root | get-acl).Access | Add-Member -MemberType NoteProperty -Name "Path" -Value $($root.fullname).ToString() -PassThru
        }
        process {
        $containers = Get-ChildItem -path $Path -recurse | ? {$_.psIscontainer -eq $true}
        if ($containers -eq $null) {break}
            foreach ($container in $containers)
            {
            (Get-ACL $container.fullname).Access | ? { $_.IsInherited -eq $false } | Add-Member -MemberType NoteProperty -Name "Path" -Value $($container.fullname).ToString() -PassThru
            }
        }
    }
    Get-PathPermissions -Path $sharePath | Select-Object -Property Path, IdentityReference, AccessControlType, FileSystemRights | Export-Csv -Path "C:\Users\mschuler\Desktop\laser\laser.csv" -NoTypeInformation