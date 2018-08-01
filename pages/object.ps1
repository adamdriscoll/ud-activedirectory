New-UDPage -Url "/object/:identity" -Endpoint {
    param($identity) 

    $Object = Get-ADObject -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties ObjectClass
    if ($Object.ObjectClass -eq "user") {
        $Object = Get-ADUser -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties *
    }
    elseif ($Object.ObjectClass -eq "computer") {
        $Object = Get-ADComputer -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties *
    }
    elseif ($Object.ObjectClass -eq "group") {
        $Object = Get-ADGroup -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties *
    }
    else {
        $Object = Get-ADObject -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties *
    }

    New-UDRow -Columns {
        New-UDColumn -Size 4 -Content {
            New-UDCard -Title $Object.DisplayName -Content {
                New-UDRow -Columns {
                    New-UDColumn -Size 4 -Content {
                        New-ADIcon -ObjectClass $Object.ObjectClass -Size 5x
                    }
                    New-UDColumn -Size 8 -Content {
                        New-UDHeading -Size 5 -Text ($Object.GivenName + " " + $Object.SurName)
                        New-UDHeading -Size 5 -Text $Object.SamAccountName

                        New-UDCheckbox -Label "Enabled" -Checked:$Object.Enabled -Disabled -OnChange {
                            #TODO: Actions
                            try {
                                if ($Object.Enabled) {
                                    Disable-ADAccount -Identity $identity @Cache:ConnectionInfo
                                }
                                else {
                                    Enable-ADAccount -Identity $identity @Cache:ConnectionInfo
                                }
                            }
                            catch {
                                Send-UDToast -Message "$_" -Duration 2000
                            }
                        }
                    }
                }
            } 
        }
        New-UDColumn -Size 4 -Content {
            #TODO: Actions!
            $Null = New-UDRow -Columns {
                New-UDButton -Icon trash -Text "Delete" -OnClick {
                    Remove-ADObject -Identity $identity @Cache:ConnectionInfo
                }
            }
        }
    }


    if ($Object.ObjectClass -eq 'user') {
        New-UDRow -Columns {
            New-UDColumn -SmallSize 12 -Content {
                New-UDCollapsible -Items {
                    New-UDCollapsibleItem -Title "Reset Password" -Icon star_half_o -Content {
                        New-UDInput -Title "Reset Password" -SubmitText "Reset" -Content {
                            New-UDInputField -Name "Password" -Placeholder "Password" -Type "password"
                        } -Endpoint {
                            param($Password)
        
                            try {
                                Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText -String $Password -Force) -Identity $identity @Cache:ConnectionInfo
                                New-UDInputAction -Toast "Password Reset" -Duration 3000
                            }
                            catch {
                                New-UDInputAction -Toast "$_" -Duration 3000
                            }
                        }
                    }
                }
            }
        }
    }

    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDTable -Title "Attributes" -Headers @("Name", "Value") -Endpoint {

                $SkippedProperties = @("PropertyNames", "AddedProperties", "ModifiedProperties", "RemovedProperties", "PropertyCount")

                $Object.psobject.Properties | ForEach-Object {

                    if ($SkippedProperties.Contains( $_.Name)) {
                        return
                    }

                    $Value = $Null
                    if ($_.Value -eq $null) {
                        $Value = ' '
                    }
                    elseif ($_.Value -is [Microsoft.ActiveDirectory.Management.ADPropertyValueCollection]) {
                        $Value = ($_.Value | ForEach-Object { 
                            $_.ToString()
                            New-UDElement -Tag "br"
                        }) 
                    }
                    else {
                        $Value = $_.Value.ToString()
                    }

                    [PSCustomObject]@{
                        Name = $_.Name 
                        Value = $Value
                    } | Out-UDTableData -Property @("Name", "Value")
                }
            }
        }
    }
}