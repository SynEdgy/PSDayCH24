class address
{
    [string] $City
    [string] $Zip

    address ()
    {
        # default ctor
    }
    
    address([System.Collections.IDictionary]$Definition)
    {
        $this.City = $Definition.City
        $this.Zip = $Definition.Zip
    }
}

class Person
{
    [string] $Name
    [int] $Age
    [address] $Address
}
