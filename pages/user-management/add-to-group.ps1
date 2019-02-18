New-UDPage -Url "/user/add-to-group" -Icon Plus -Endpoint {
    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDInput -Title "Add to Group" -SubmitText "Add" -Content {
                New-UDInputField -Name "UserName" -Placeholder "Account Name" -Type "textbox"
                New-UDInputField -Name "GroupName" -Placeholder "Group Name" -Type "textbox"
            } -Endpoint {
                param(
                    $UserName,
                    $GroupName
                )
        
                try 
                { 
                    Add-ADGroupMember -Identity $GroupName -Members (Get-ADUser -Identity $UserName @Cache:ConnectionInfo) @Cache:ConnectionInfo
                    New-UDInputAction -RedirectUrl "/object/$UserName"
                }
                catch 
                {
                    New-UDInputAction -Toast "Failed to add user to group. $_"
                }
            }
        }
    }
}