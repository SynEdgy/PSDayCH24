# En PowerSell on utilise certains types d'objets courramment

# Tableau pour une liste d'objets dans un certain ordre
$tableau = @('a', 'b', 'c')
$tableau

# Le tableau est un terme generique pour une liste d'objets
# le type peut etre different
$tableau.GetType().Tostring()

# Comme tout est objet, le type [object] est tres generique, et d'autres types peuvent etre ajoutés
$tableau += 1

# mais ce tableau est un objet, il a une propriété Count
$tableau.Count

# On accete au elements par leur index
$tableau[0]

# certains index peuvent etre negatifs
$tableau[1]

# la valeur de l'objet a un index nous retourne l'objet lui meme
$tableau[-1].GetType().ToString()
$tableau[0].GetType().ToString()
