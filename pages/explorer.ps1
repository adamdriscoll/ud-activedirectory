New-UDPage -Name "Explorer" -Icon folder -Content {
    New-UDRow -Columns {
        New-UDColumn -SmallSize 12 -LargeSize 3 -Content {

            $Domain = Get-ADDomain @Cache:ConnectionInfo 

            $DomainNode = New-UDTreeNode -Name $Domain -Id "domain"
            New-UDTreeView -Node $DomainNode -OnNodeClicked {
                param($Body)
                $Obj = $Body | ConvertFrom-Json

                if ($Obj.NodeId -eq 'domain') {
                    Get-ChildItem -Path "AD:\" | ForEach-Object {
                        New-UDTreeNode -Name $_.Name -Id $_.DistinguishedName
                    }
                }
                else 
                {
                    Get-ChildItem -Path "AD:\$($Obj.NodeId)" | ForEach-Object {
                        New-UDTreeNode -Name $_.Name -Id $_.DistinguishedName
                    }
                }
            }
        }
        New-UDColumn -SmallSize 12 -LargeSize 9 {

        }
    }
}