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

        New-UDColumn -Size 1 -Content {
            New-UDButton -Icon check -Text "Enable" -OnClick {
                Enable-ADAccount -Identity $identity @Cache:ConnectionInfo
            }
        }
        New-UDColumn -Size 1 -Content {
            New-UDButton -Icon star -Text "Reset Password" -OnClick {
                Show-UDModal -Header { "Reset Password" } -Content {
                    New-UDTextbox -Id "txtResetPassword" -Label "New Password" -Placeholder "New Password" -Type "password"
                } -Footer {
                    New-UDButton -Id "btnResetPassword" -Text "Reset" -OnClick {
                        $Element = Get-UDElement -Id "txtResetPassword" 
                        $Password = $Element.Attributes["value"]

                        Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText -String $Password) -Identity $identity @Cache:ConnectionInfo
                    }
                }
            }
        }
        New-UDColumn -Size 1 -Content {
            New-UDButton -Icon trash -Text "Delete" -OnClick {
                Remove-ADObject -Identity $identity @Cache:ConnectionInfo
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