install-module -name powershell-yaml
Import-Module -name powershell-yaml
Get-Command -Module powershell-yaml

# lire un fichier

Get-Content -Raw -Path .\1.base.yml | ConvertFrom-Yaml

# Dans l'autre sens...

[pscustomobject]@{
    Name = "Gael"
    Age = 40
    Address = [pscustomobject]@{
        City = "St Legier"
        Zip = 1806
    }
} | ConvertTo-Yaml 

# Manipulation

$objets = Get-Content -Raw -Path .\2.extra.yml | ConvertFrom-Yaml
$objets.objets

$objets

# multi-documents
$objets = Get-Content -Raw -Path .\2.extra.yml | ConvertFrom-Yaml -AllDocuments
$objets[1].AutreDocument