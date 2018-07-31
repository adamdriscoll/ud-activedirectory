New-UDPage -Url "/object/:identity" -Endpoint {
    param($identity) 

    $Object = Get-ADObject -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties *

    New-UDRow -Columns {
        New-UDColumn -Size 4 -Content {
            New-UDCard -Title $Object.DisplayName -Content {
                New-UDHeading -Size 5 -Text ($Object.GivenName + " " + $Object.SurName)
                New-UDHeading -Size 5 -Text $Object.SamAccountName
                New-UDHeading -Size 5 -Text ("Enabled: " + $Object.Enabled)
            }
        }
    }

    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDTable -Title "Attributes" -Headers @("Name", "Value", "Save") -Endpoint {
                $Object.psobject.Properties | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_.Name 
                        Value = if ($_.value -eq $null) {" "} else { $_.Value.ToString() }
                        Save = New-UDButton -Text "Save" -OnClick {}
                    } | Out-UDTableData -Property @("Name", "Value", "Save")
                }
            }
        }
    }
}