$ComputerName = "Server123"
$ComputerOwner = "Stephane van Gulick"
$ComputerType = "SAP"

$Comp = New-Object -TypeName PSObject

Add-Member -InputObject $Comp -Type NoteProperty -Name Name -Value $ComputerName
Add-Member -InputObject $Comp -Type NoteProperty -Name Owner -Value $ComputerOwner
Add-Member -InputObject $Comp -Type NoteProperty -Name Type -Value $ComputerType

$Comp