# Le type d'un objet custom est le suivant
([PSCustomObject]@{
    Name  = 'Value'
    Name1 = 'Value1'
    Name2 = 'Value2'
    Name3 = [PSCustomObject]@{
        subProp31  = 'Value31'
        subProp32 = 'Value32'
    }
}).GetType().ToString()

# Mais grace a PowerShell on peut ajouter un "pseudo type" aux objets custom
$newObj = [PSCustomObject]@{
    pstypeName = 'MyObjectType'
    Name  = 'Value'
    OtherProp = 'OtherValue'
}

# Ce n'est pas une propriété
$newObj

# Mais l'information est bien enregistrée
$newObj.psobject.typeNames
$newObj.pstypenames

# au passage, on peut connaitre les proprietes d'un objet grace a Get-Member ou la propriete psobject
$newObj.psobject.Properties.name
#Update-TypeData -TypeName 'MyType' -MemberType ScriptProperty -MemberName 'MyProperty' -Value { $this.Name + ' ' + $this.Name1 + ' ' + $this.Name2 + ' ' + $this.Name3.subProp31 + ' ' + $this.Name3.subProp32 }