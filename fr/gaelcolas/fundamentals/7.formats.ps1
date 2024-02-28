# ce que vous voyez n'est qu'une representation de l'objet
# l'affichage des objets est formatté, PoweShell essaye de faire de son mieux
[PSCustomObject]@{
    Prop  = 'Value'
    Prop1 = 'Value1'
    Prop2 = 'Value2'
}

[PSCustomObject]@{
    Name  = 'Value'
    Name1 = 'Value1'
    Name2 = 'Value2'
    Name3 = 'Value3'
}

# On peut changer le format d'affichage, sans changer l'objet

$myObj = [PSCustomObject]@{
    Name  = 'Value'
    Name1 = 'Value1'
    Name2 = 'Value2'
    Name3 = 'Value3'
}

$myObj | Format-List
$myObj | Format-Table

# Des fois, pour afficher un objet et sa structure, on peut utiliser ConvertTo-Json
[PSCustomObject]@{
    Name  = 'Value'
    Name1 = 'Value1'
    Name2 = 'Value2'
    Name3 = [PSCustomObject]@{
        subProp31  = 'Value31'
        subProp32 = 'Value32'
    }
} | ConvertTo-Json