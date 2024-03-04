function Get-UserInfo {
    Param(
        [String]$FirstName,
        [String]$LastName,
        [int]$Age
    )

    $FullName = $LastName.Substring(0,3) + $FirstName.SubString(0,1)
    $obj = [PsCustomObject]@{"LastName"=$LastName;"FirstName"=$FirstName;"FullName"=$FullName;"Age"=$Age}

    return $obj
}


Function New-UserFolder {
    Param(
        $Input,
        $BasePath = "C:\Plop\"
    )

    $FullPath = Join-Path -Path $BasePath -ChildPath $Input.FullName
    write-host "Creating User Folder for $($Input.FirstName) $($Input.LastName) at $($FullPath)"
    
    New-Item -Path $FullPath -ItemType Directory -Name $Input.FullName
}

Function New-ADStandardUser{
    Param(
        $Input  
    )

    write-host "Creating AD Standard User for $($Input.FirstName) $($Input.LastName)" -ForegroundColor Cyan
}

Function New-ADAdminUser {
    Param(
        $Input  
    )

    write-host "Creating AD Admin User for $($Input.FirstName) $($Input.LastName)" -ForegroundColor Magenta

}

Function New-Maison{
    Param(
        [ValidateSet("Bleu","Blanc","Rouge")]$Couleur
    )

    write-host "La maison est de couleur: $($couleur)"
}