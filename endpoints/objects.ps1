New-UDEndpoint -Endpoint {
    try 
    {
        $Objects = Get-ADObject -Filter { Name -like '*'} @Cache:ConnectionInfo
        $Cache:Classes = $Objects | Group-Object -Property ObjectClass | Sort-Object -Property Count -Descending | Select-Object -First 10

        $Computers = $Objects | Where-Object ObjectClass -eq 'computer'

        $DomainControllers = Get-ADDomainController @Cache:ConnectionInfo

        $Cache:Computers = @{
            Total = ($Computers | Measure-Object).Count
            Disabled = ($Computers | Where-Object Enabled -eq $false | Measure-Object).Count
            'Domain Controllers' = ($DomainControllers | Measure-Object).Count
        }.GetEnumerator()

        $Users = Get-ADUser -Filter { Name -like '*'} @Cache:ConnectionInfo -Properties *
         
        $Cache:Users = @{
            Total = ($Users | Measure-Object).Count
            Disabled = ($Users | Where-Object Enabled -eq $false | Measure-Object).Count
        }.GetEnumerator()

        $Cache:Forest = Get-ADForest @Cache:ConnectionInfo
        $Cache:Domains = Get-ADDomain @Cache:ConnectionInfo
    }
    catch 
    {
        $Cache:Error = "Failed to load AD data. $_"
    }
    finally 
    {
        $Cache:Loading = $false
    }
}-Schedule (New-UDEndpointSchedule -Every 30 -Second)