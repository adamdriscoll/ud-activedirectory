New-UDPage -Url "/user/reset-password" -Icon Plus -Endpoint {
    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDInput -Title "Reset Password" -SubmitText "Reset Password" -Content {
                New-UDInputField -Name "UserName" -Placeholder "Account Name" -Type "textbox"
                New-UDInputField -Name "Password" -Placeholder "Password" -Type "password"
            } -Endpoint {
                param(
                    $UserName,
                    $Password
                )
        
                try 
                { 
                    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
                    Set-ADAccountPassword -Reset -NewPassword $SecurePassword -Identity $UserName @Cache:ConnectionInfo
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