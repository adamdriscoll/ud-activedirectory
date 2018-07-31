New-UDPage -Url "/user/create" -Icon Plus -Endpoint {
    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDInput -Title "Create User" -SubmitText "Create" -Content {
                New-UDInputField -Name "FirstName" -Placeholder "First Name" -Type "textbox"
                New-UDInputField -Name "LastName" -Placeholder "Last Name" -Type "textbox"
                New-UDInputField -Name "UserName" -Placeholder "Account Name" -Type "textbox"
            } -Endpoint {
                param(
                    $FirstName,
                    $LastName,
                    $UserName
                )
        
                try 
                {
                    New-ADUser -Name $UserName -GivenName $FirstName -Surname $LastName @Cache:ConnectionInfo
                    New-UDInputAction -RedirectUrl "/object/$UserName"
                }
                catch 
                {
                    New-UDInputAction -Toast "Failed to add user. $_"
                }
            }
        }
    }
}