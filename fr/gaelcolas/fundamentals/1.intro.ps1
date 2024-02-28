# le shell interactif peut executer des commandes

notepad.exe .\1.intro.ps1

# on peut definir du texte

"Voici un peu de texte"

# et toute est objet

"Voici un peu de texte".Length

# si tout est objet, tout est typé

"Voici un peu de texte".GetType().ToString()

# Je peux mettre une valeur dans une variable sans definir son type

$texte = "Voici un peu de texte"
$texte.GetType().ToString()

# Je peux changer de valeur et de type

$texte = 10
$texte.GetType().ToString()

# Je peux aussi typer une variable

[int] $nombre = 10
$nombre.GetType().ToString()

# Et maintenant je ne peux plus changer son type
$nombre = 'du texte'
