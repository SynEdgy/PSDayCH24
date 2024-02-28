# Sans créer de classe, on peut créer des objets personnalisés
$obj = [PSCustomObject]@{
    Property = 'Value'
    Property2 = 'Value2'
}

# On peut aussi créer des objets avec des méthodes

$obj | Add-Member -MemberType ScriptMethod -Name DoSomething -Value {
    param($param)
    "I'm a method with param $param and property value $($this.Property)"
} -Force

$obj.DoSomething('ABC')

# (Note sur copilot: des fois il propose n'importe quoi)
# $obj = [PSCustomObject]@{
#     Property = 'Value'
#     Property2 = 'Value2'
#     Method = {
#         param($param)
#         "I'm a method with param $param"
#     }
# }
