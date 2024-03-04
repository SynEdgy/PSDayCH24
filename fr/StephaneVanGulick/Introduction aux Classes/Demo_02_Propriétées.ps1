class maison {

    [String]$Couleur
    [int]$Habitants

}

new-object maison

$maMaison = [maison]::New()

$OSDParameterHash = @{"TestVar1"="plop";"TestVar2"="woop"}
[String]$Commande = "-File OSDScript.ps1"
foreach($para in $OSDParameterHash.Keys){
    $Commande += " -$($para) " + $OSDParameterHash[$para]
}

$Commande

$ArgumentList = '-NoLogo -NoExit',"-File OSDScript.ps1 {0}" -f $Global:OSDParametersHash
Start-Process -WorkingDirectory "C:\Users\JM2K69\AppData\Local\Temp" -FilePath PowerShell.exe -ArgumentList $ArgumentList