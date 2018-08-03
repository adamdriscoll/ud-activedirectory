New-UDPage -Name "Search" -Icon search -Content {

    New-UDElement -Tag "div" -Attributes @{
        style = @{
            height = '25px'
        }
    }

    New-UDRow -Columns {
        New-UDColumn -Size 10 -SmallOffset 1 -Content {
            New-UDRow -Columns {
                New-UDColumn -Size 10 -Content {
                    New-UDTextbox -Id "txtSearch" -Label "Search" -Placeholder "Search for an object" -Icon search
                }
                New-UDColumn -Size 2 -Content {
                    New-UDButton -Id "btnSearch" -Text "Search" -Icon search -OnClick {
                        $Element = Get-UDElement -Id "txtSearch" 
                        $Value = $Element.Attributes["value"]
        
                        Set-UDElement -Id "results" -Content {
                            New-UDGrid -Title "Search Results for: $Value" -Headers @("Name", "More Info") -Properties @("Name", "MoreInfo") -Endpoint {
                                $Objects = Get-ADObject -Filter "Name -like '$Value' -or samAccountName -like '$Value'" -ResultSetSize 20 @Cache:ConnectionInfo -IncludeDeletedObjects
                                $Objects | ForEach-Object {
                                    [PSCustomObject]@{
                                        Name = $_.Name
                                        MoreInfo = New-UDButton -Text "More Info" -OnClick {
                                            Invoke-UDRedirect -Url "/object/$($_.Name)"
                                        }
                                    }
                                } | Out-UDGridData 
                            } 
                        }
                    }
                }
            }
        }
    }

    New-UDRow -Columns {
        New-UDColumn -SmallSize 10 -SmallOffset 1 {
            New-UDElement -Tag "div" -Id "results"
        }
    }
}