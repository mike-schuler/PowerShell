Import-Module activedirectory

#import site info from json file
$siteInfo = Get-Content -Path ".\siteInfo.json" | ConvertFrom-Json


function show-menu {
    $menu = @(
        "1. Create new user"
        "2. Create new group"
        "3. Add user to group"
        "4. Remove user from group"
        "5. Delete user"
        "6. Delete group"
        "7. Exit"
    )
    $menu | Out-Host
    $choice = Read-Host "Enter your choice"
    return $choice
}

#Display list of sites from sites in json file.
function show-siteMenu {
    $menu = @()
    $menu += "0. Exit"
    $i = 1
    foreach ($site in $siteInfo.sites) {
        $menu += "$i. $($site.name)"
        $i++
    }
    $menu | Out-Host
    $choice = Read-Host "Enter your choice"
    return $choice
}

#Used to select a site from the list of sites in the json file.
function select-activeSite {
    $choice = show-siteMenu
    if ($choice -eq 0) {
        main
    }
    $site = $siteInfo.sites[$choice - 1]
    return $site
}

#function to genrate new user name
function genrate-username {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $firstName,
        [Parameter()]
        [String]
        $lastName
    )

    $userName = "$($firstName.Substring(0,1))$($lastName)"
    $userName = $userName.ToLower()
    return $userName

}

#function to generate random pasword for new user
function genrate-password {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $length = 14
    )

    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    $password = ""
    for ($i = 0; $i -lt $length; $i++) {
        $password += $chars.Substring((Get-Random -Maximum $chars.Length), 1)
    }
    return $password
}

#function to generate new user email address
function genrate-email {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $userName,
        [Parameter()]
        [String]
        $domain
    )

    $email = "$($userName)@$($domain)"
    return $email
}


#function to create new user
function mainCreateBusinessUser {
    write-host "New Business User Creation Menu"
    $activeSite = select-activeSite
    if($activeSite -eq $null) {
        Write-Host "Please select a valid site"
        mainCreateBusinessUser
    }
    write-host "You have selected $($activeSite.name)"



}


#main to run script and handel application flow
function main {
    $showMenuSelection = show-menu
    switch ($showMenuSelection) {
        1 {mainCreateBusinessUser}
        7 {exit}
        Default {
            write-host "Feature not implemented yet or invalid choice."
            main
        }
    }




}

main