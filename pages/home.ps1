New-UDPage -Name "Home" -Icon home -Content {
    New-UDRow -Endpoint {
        New-UDColumn -Size 12 -Content {
            if ($Cache:Loading) {
                New-UDPreloader -Circular 
            }
            elseif ($Cache:Error -ne $null) 
            {
                New-UDCard -Title "Error loading data" -Content {
                    $Cache:Error
                }
            }
            else 
            {
                New-UDRow -Columns {
                    New-UDColumn -SmallSize 4 -Content {
                        New-UDChart -Type Bar -Title "Users" -Endpoint {
                            $Cache:Users | Out-UDChartData -DataProperty 'Value' -LabelProperty 'Name' -BackgroundColor $Cache:ChartColorPalette
                        }
                    }
                    New-UDColumn -SmallSize 4 -Content {
                        New-UDChart -Type Bar -Title "Computers" -Endpoint {
                            $Cache:Computers | Out-UDChartData -DataProperty 'Value' -LabelProperty 'Name' -BackgroundColor $Cache:ChartColorPalette
                        }
                    }
                    New-UDColumn -SmallSize 4 -Content {
                        New-UDChart -Type Pie -Id 'ObjectClasses' -Title "Top Classes" -Endpoint {
                            $Cache:Classes | Out-UDChartData -DataProperty 'Count'  -LabelProperty 'Name' -BackgroundColor $Cache:ChartColorPalette
                        }
                    }
                }

                New-UDRow -Columns {
                    New-UDColumn -Size 12 -Content {
                        New-UDTable -Title "Forest" -Headers @("Name", "Root Domain", "Mode") -Endpoint {
                            $Cache:Forest | ForEach-Object {
                                [PSCustomObject]@{
                                    Name = $_.Name
                                    RootDomain = $_.RootDomain
                                    ForestMode = $_.ForestMode.ToString()
                                }
                            } | Out-UDTableData -Property @("Name", "RootDomain", "ForestMode")
                        } -Style highlight
                    }
                }

                New-UDRow -Columns {
                    New-UDColumn -Size 12 -Content {
                        New-UDTable -Title "Domains" -Headers @("Name", "Forest", "Mode", "DNS Root") -Endpoint {
                            $Cache:Domains | ForEach-Object {
                                [PSCustomObject]@{
                                    Name = $_.Name
                                    Forest = $_.Forest
                                    DomainMode = $_.DomainMode.ToString()
                                    DnsRoot = $_.DNSRoot
                                }
                            } | Out-UDTableData -Property @("Name", "Forest", "DomainMode", "DNSRoot")
                        } -Style highlight
                    }
                }
            }
        }
    }
}