
# Un Dictionnaire est une liste d'objets avec des clés, sans ordre precis
$dictionnaire = @{'a' = 1; 'c' = 3; 'b' = 2}
$dictionnaire

# on accede aux valeurs par leur clé
$dictionnaire['a']

# La valeur d'une clé est l'objet, on peut donc acceder a ses methodes
$dictionnaire['a'].GetType().ToString()

# On peut ajouter des clés
$dictionnaire['d'] = 4
$dictionnaire.Add('key', 'value')
$dictionnaire

# On peut supprimer des clés
$dictionnaire.Remove('key')

# on peut acceder a la liste des clés
$dictionnaire.Keys

# la liste des clés est un tableau
$dictionnaire.Keys.count

# mais il est d'un type different
$dictionnaire.Keys.GetType().ToString()