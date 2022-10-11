#Script to semi-automate help desk ad functions
#Author: Mike Schuler
#Date: 2022-10-11

#require admin rights
#require AD module
Import-Module activedirectory

#import site info from json file
$siteInfo = Get-Content -Path ".\siteInfo.json" | ConvertFrom-Json


function show-menu {
    $menu = @(
        "0. Exit"
        "1. Create new user"
        "2. Create new group"
        "3. Add user to group"
        "4. Remove user from group"
        "5. Delete user"
        "6. Delete group"
        
    )
    $menu | Out-Host
    $choice = Read-Host "Enter your choice"
    return $choice
}

#Displays list of sites from sites in json file.
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

#generates the usersname from the first and last name in the follwoing format: firstinitiallastname
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
    $userNameExists = check-username -userName $userName
    $x = 1
    while($userNameExists) {
        $userName = "$($userName)$($x)"
        $userNameExists = check-username -userName $userName
        $x++
    }

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

#function to check if ad user exists and returns true or false
function check-username {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $userName
    )

    $user = Get-ADUser -Filter {SamAccountName -eq $userName} -Properties SamAccountName
    if ($user) {
        return $true
    }
    else {
        return $false
    }
}
#function to get departments from active sites and display menu
function show-departmentMenu {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $site
    )

    $menu = @()
    $menu += "0. Exit"
    $i = 1
    foreach ($department in $activeSite.departments) {
        $menu += "$i. $($department.name)"
        $i++
    }
    $menu | Out-Host
    $choice = Read-Host "Enter your choice"
    return $choice
}

#function to select a department from the list of departments in the json file.
function select-activeDepartment {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $site
    )

    $choice = show-departmentMenu -site $site
    if ($choice -eq 0) {
        main
    }
    $department = $activeSite.departments[$choice - 1]
    return $department
}



#handles logic for creating new business user
function mainCreateBusinessUser {
    write-host "Creating new business user"
    $activeSite = select-activeSite
    if($activeSite -eq $null) {
        main
    }
    $activeDepartment = select-activeDepartment -site $activeSite.name
    if($activeDepartment -eq $null) {
        main
    }
    #get basic user info from user
    $firstName = Read-Host "Enter first name"
    $lastName = Read-Host "Enter last name"
    if ($firstName -eq "" -or $lastName -eq "") {
        write-host "First name and last name are required"
        main
    }
    
    #automatic generate additional user info from user input
    $userName = genrate-username -firstName $firstName -lastName $lastName
    $password = genrate-password
    $email = genrate-email -userName $userName -domain $activeSite.domain


    write-host Department: $activeDepartment.name
    write-host Site: $activeSite.name
    $choice = Read-Host "Is this correct? (y/n)"
    if($choice -eq "y") {
        #create user
        $user = New-ADUser -Name "$($firstName) $($lastName)" `
            -GivenName $firstName `
            -Surname $lastName `
            -SamAccountName $userName `
            -UserPrincipalName $email `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -PasswordNeverExpires $false `
            -AccountNotDelegated $false `
            -streetAddress $activeSite.streetaddress `
            -City $activeSite.city `
            -State $activeSite.state `
            -PostalCode $activeSite.postalcode `
            -Country $activeSite.country `
            -OfficePhone $activeSite.phone `
            -Title $activeDepartment.title `
            -Company $activeSite.name `
            -Department $activeDepartment.name `
            -DisplayName "$($firstName) $($lastName)" `
            -HomeDrive $activeSite.homedrive `
            -HomeDirectory ($activeSite.homedir + $userName) `
            -ScriptPath $activeSite.scriptpath `
            -Description "Created by script" `
            -Path $activedepartment.path `
            -webpage $activeSite.webpage `
            -PassThru 
         

        write-host "User created"
        write-host "User name: $userName"
        write-host "Password: $password"
        write-host "Email: $email"
        
    }
    else {
        write-host "User not created"
    }

    main    
}


#main to run script and handel application flow
function main {
    $showMenuSelection = show-menu
    switch ($showMenuSelection) {
        1 {mainCreateBusinessUser}
        0 {exit}
        Default {
            write-host "Feature not implemented yet or invalid choice."
            main
        }
    }




}

main