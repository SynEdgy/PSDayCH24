Enum Couleur {
    Bleu
    Blanc
    Rouge
}


Function New-Maison{
    Param(
        [ValidateSet("Bleu","Blanc","Rouge")]$Couleur
    )

    write-host "La maison est de couleur: $($couleur)"
}

Function New-Maison{
    Param(
        [Couleur]$Couleur
    )

    write-host "La maison est de couleur: $($couleur)"
}