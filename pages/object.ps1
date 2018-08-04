New-UDPage -Url "/object/:identity" -Endpoint {
    param($identity) 

    $Object = Get-ADObject -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties ObjectClass -IncludeDeletedObjects
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
        $Object = Get-ADObject -Filter { Name -eq $Identity } @Cache:ConnectionInfo -Properties * -IncludeDeletedObjects
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
                    }
                }
            } 
        }

        if (-not $Object.Deleted) {
            New-UDColumn -Size 4 -Content {
                New-UDElement -Tag "div" -Attributes @{ style = @{ height = "10px"}}
                New-UDButton -Icon trash -Text "Delete" -OnClick {
                    Show-UDModal -Header { New-UDHeading -Size 5 -Text "Are you sure you want to delete this object?" } -Content {

                        New-UDHeading -Size 5 -Text "Clicking ok will run: Remove-ADObject -Identity $identity -Confirm:`$false"

                        New-UDRow -Columns {
                            New-UDColumn -Size 2 -Content {
                                New-UDButton -Text "Ok" -OnClick {
                                    Remove-ADObject -Identity $identity @Cache:ConnectionInfo -Confirm:$false
                                    Hide-UDModal
                                    Invoke-UDRedirect -Url "/home"
                                } -Icon warning
                            }
                            New-UDColumn -Size 2 -Content {
                                New-UDButton -Text "Cancel" -OnClick {
                                    Hide-UDModal
                                }
                            }
                        }
                    } 
                }

                if ($Object.ObjectClass -eq "user" -or $Object.ObjectClass -eq "computer") {
                    $EnabledText = "Enable"
                    $btnIcon = 'check'
                    if ($Object.Enabled) {
                        $EnabledText = "Disable"
                        $btnIcon = 'xing'
                    }

                    New-UDElement -Tag "div" -Attributes @{ style = @{ height = "10px"}} -Content {}
                    New-UDButton -Id "btnEnabled" -Icon $btnIcon -Text $EnabledText  -OnClick {
                        if ($Object.Enabled) {
                            Disable-ADAccount -Identity $identity @Cache:ConnectionInfo
                            Set-UDElement -Id "btnEnabled" -Content {
                                New-UDIcon -Icon 'check'
                                "Enable"
                            }
                        }
                        else {
                            Enable-ADAccount -Identity $identity @Cache:ConnectionInfo
                            Set-UDElement -Id "btnEnabled" -Content {
                                New-UDIcon -Icon 'xing'
                                "Disable"
                            }
                        }
                    }
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

    if ($Object.ObjectClass -eq 'group') {
        New-UDRow -Columns {
            New-UDColumn -SmallSize 12 -Content {
                New-UDCollapsible -Items {
                    New-UDCollapsibleItem -Title "Members" -Icon users -Content {
                        New-UDTable -Id "members" -Headers @("Name", "Remove") -Endpoint {
                            Get-ADGroupMember -Identity $identity @Cache:ConnectionInfo | ForEach-Object {
                                $member = $_
                                [PSCustomObject]@{
                                    Name = $_.name
                                    Remove = New-UDButton -Text "Remove" -OnClick {
                                        Remove-ADGroupMember -Identity $identity @Cache:ConnectionInfo -Members $member -Confirm:$false 
                                    }
                                }
                            } | Out-UDTableData -Property @("Name", "Remove")
                        } -AutoRefresh -RefreshInterval 5
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