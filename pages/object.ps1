New-UDPage -Url "/object/:identity" -Endpoint {
    param($identity) 

    $Object = Get-ADObject -Filter { Name -eq $Identity } @Cache:ConnectionInfo
 
    New-UDCard -Title $identity
    New-UDCard -Title $Object.ObjectClass
}