New-UDPage -Name 'User Management' -Icon user_circle_o -Content {
    New-UDElement -Tag "div" -Attributes @{ className = 'container' } -Content {
        New-UDCollection -Header "User Management" -LinkCollection -Content {
            New-UDCollectionItem -Url "/user/create" -Content {
                New-UDIcon -Icon plus_circle 
                "     Create User"
            }
        }
    }
}