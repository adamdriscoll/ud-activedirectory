function Start-UDActiveDirectoryDashboard {
    param(
        [Parameter()]
        [string]$Server,
        [Parameter()]
        [PSCredential]$Credential,
        [Parameter()]
        [int]$Port = 10001
    )

    $Cache:Loading = $true
    $Cache:ChartColorPalette = @('#5899DA', '#E8743B', '#19A979', '#ED4A7B', '#945ECF', '#13A4B4', '#525DF4', '#BF399E', '#6C8893', '#EE6868', '#2F6497')
    $Cache:ConnectionInfo = @{
        Server = $Server
        Credential = $Credential
    }

    $Utilities = (Join-Path $PSScriptRoot 'udad-init.psm1')
    Import-Module  $Utilities

    $Pages = Get-ChildItem (Join-Path $PSScriptRoot 'pages') -Recurse -File | ForEach-Object {
        & $_.FullName
    } 

    $Endpoints = Get-ChildItem (Join-Path $PSScriptRoot 'endpoints') | ForEach-Object {
        & $_.FullName
    }

    $AuthenticationMethod = New-UDAuthenticationMethod -Endpoint {
        param([PSCredential]$Credentials)

        try 
        {
            Write-UDLog -Message $Credentials.UserName
            Write-UDLog -Message $Credentials.GetNetworkCredential().Password 
            Write-UDLog -Message $Cache:ConnectionInfo.Server
            Get-ADObject -Credential $Credentials -Server $Cache:ConnectionInfo.Server -Filter "*" -ResultSetSize 1 | Out-Null
            New-UDAuthenticationResult -Success -UserName $Credentials.UserName
        }
        catch 
        {
            Write-UDLog -Message $_
            New-UDAuthenticationResult 
        }
    }

    $LoginPage = New-UDLoginPage -AuthenticationMethod $AuthenticationMethod

    $EndpointInit = New-UDEndpointInitialization -Module 'udad-init.psm1'

    $Navigation = New-UDSideNav -Content {
        New-UDSideNavItem -Text "Home" -Url "Home" -Icon home
        New-UDSideNavItem -Text "Deleted Objects" -Url "deleted-objects" -Icon user_times
        New-UDSideNavItem -Text "Explorer" -Url "Explorer" -Icon folder
        New-UDSideNavItem -Text "Search" -Url "Search" -Icon search
        New-UDSideNavItem -Text "User Management" -Icon user  -Children {
            New-UDSideNavItem -Text "Add User To Group" -Url "user/add-to-group" -Icon user_plus
            New-UDSideNavItem -Text "Create User" -Url "user/create" -Icon plus_circle
            New-UDSideNavItem -Text "Reset Password" -Url "user/reset-password" -Icon code
        }
    }

    $Dashboard = New-UDDashboard -Title "Active Directory" -Pages $Pages -EndpointInitialization $EndpointInit -LoginPage $LoginPage -Navigation $Navigation
    
    Start-UDDashboard -Dashboard $Dashboard -Endpoint $Endpoints -Port $Port -AllowHttpForLogin
}

