# les boucles nous permettent de répéter des actions, ou de parcourir des collections
$tableau = @('a', 'b', 'c')
foreach ($element in $tableau) {
    "foreach Element: $element"
}

# on peut aussi utiliser la boucle for
for ($i = 0; $i -lt $tableau.Count; $i++) {
    "for Element: $($tableau[$i])"
}

# ou while
$i = 0
while ($i -lt $tableau.Count) {
    "while Element: $($tableau[$i])"
    $i++
}

# Pour les dictionnaires, on peut utiliser la boucle foreach sur les clefs
$dictionnaire = @{'a' = 1; 'c' = 3; 'b' = 2}
foreach ($key in $dictionnaire.Keys) {
    "Key: $key, value: $($dictionnaire[$key])"
}

# Attention, on ne peux pas modifier la collection en cours de boucle
$dictionnaire = @{'a' = 1; 'c' = 3; 'b' = 2}
foreach ($key in $dictionnaire.Keys) {
    "Key: $key, value: $($dictionnaire[$key])"
    if ($key = 'c') {
        $dictionnaire.Add('d',4)
    }
}

# Pour les dictionaires, on peut aussi utiliser un switch
$dictionnaire = @{'a' = 1; 'c' = 3; 'b' = 2}
switch ($dictionnaire.keys)
{
    'a' {'I ''m an A'}
    'c' {'I ''m an C'}
    default {'I ''m an {0}' -f $_.ToUpper()}
}