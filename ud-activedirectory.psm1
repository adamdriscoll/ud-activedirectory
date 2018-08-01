function Start-UDActiveDirectoryDashboard {
    param(
        [Parameter()]
        [string]$Server,
        [Parameter()]
        [PSCredential]$Credential
    )

    $Utilities = (Join-Path $PSScriptRoot 'utils.ps1')
    . $Utilities

    $Cache:Loading = $true
    $Cache:ChartColorPalette = @('#5899DA', '#E8743B', '#19A979', '#ED4A7B', '#945ECF', '#13A4B4', '#525DF4', '#BF399E', '#6C8893', '#EE6868', '#2F6497')
    $Cache:ConnectionInfo = @{
        Server = $Server
        Credential = $Credential
    }

    $Pages = Get-ChildItem (Join-Path $PSScriptRoot 'pages') -Recurse -File | ForEach-Object {
        & $_.FullName
    } 

    $Endpoints = Get-ChildItem (Join-Path $PSScriptRoot 'endpoints') | ForEach-Object {
        & $_.FullName
    }

    $Dashboard = New-UDDashboard -Title "Active Directory" -Pages $Pages -EndpointInitializationScript {
        . $Utilities
    }
    
    Start-UDDashboard -Dashboard $Dashboard -Endpoint $Endpoints -Port 10001 
}

