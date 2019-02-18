New-UDPage -Name "Deleted Objects" -Content {
    New-UDGrid -Title "Deleted Objects" -Headers @("Name", "Distinguished Name") -Properties @("Name", "DistinguishedName") -Endpoint {
        Get-ADObject -Filter {(isdeleted -eq $true) -and (name -ne "Deleted Objects")} -includeDeletedObjects @Cache:ConnectionInfo | Out-UDGridData 
    }
}