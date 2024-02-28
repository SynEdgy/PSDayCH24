
# Si tout est objet, tout objet a propriété et methode
[int]$nombre = 10
$nombre | Get-Member

# methode
$nombre.Equals(20)
$nombre.Equals(10)

# les methodes ont des signatures, qui definissent leur parametres
# appeler la methode sans les paratheses affiche la signature
$nombre.compareTo

# et vous pouvez appeler differentes signatures avec des parametres differents
$nombre.compareTo(20)
$nombre.compareTo(10)
$nombre.compareTo(1)

# Pour "vider" une variable, il faut lui donner la valeur $null
$nombre = $null
$nombre

# Mais certain types ne supportent pas $null comme valeur
[string]$myString = 'abc'
$myString = $null
$myString

# Est-ce null? non
$null -eq $myString
'' -eq $myString

# finalement, on peut appeler des methodes statiques de classes
[string]::IsNullOrEmpty($myString)

# comprendre PowerShell c'est comprendre ces fondamentaux,
# et des parties de librairies disponible
