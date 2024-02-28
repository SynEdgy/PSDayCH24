class BaseClass
{
    BaseClass()
    {
        # Default ctor
    }

    hidden [void] _setProperties ([System.Collections.IDictionary]$Definition)
    {
        foreach ($key in $Definition.Keys)
        {
            if ($this.PSObject.Properties[$key].isSettable)
            {
                $this.($key) = $Definition[$key]
            }
            else
            {
                Write-Warning -Message ('Key {0} is not settable' -f $key)
            }
        }
    }

    hidden [void] _setProperties ([PSCustomObject] $Definition)
    {
        $Definition.PSObject.Properties.name.Foreach{
            if ($this.PSObject.Properties[$_].isSettable)
            {
                $this.($_) = $Definition.($_)
            }
            else
            {
                Write-Warning -Message ('Key {0} is not settable' -f $_)
            }
        }
    }

    hidden static [object[]] Load([string] $fileName)
    {
        return (Get-Content -Raw -Path $fileName | ConvertFrom-Yaml -AllDocuments -UseMergingParser | ForEach-Object -Process {
            [organiser] $_
        })
    }
}

class home : BaseClass
{
    [string] $City
    [string] $Zip
}

class organiser : BaseClass
{
    [string] $Name
    [int] $age
    [home] $address

    organiser ([string] $fileName)
    {
        $this._setProperties((Get-Content -Raw -Path $fileName | ConvertFrom-Yaml))
    }

    organiser ([PSCustomObject] $Definition)
    {
        $this._setProperties($Definition)
    }

    organiser ([System.Collections.IDictionary]$Definition)
    {
        $this._setProperties($Definition)
    }
}

break
# creer l'objet depuis un objet/hashtable
$a = [organiser]([PSCustomObject]@{name='Willy';age=44;address=@{City='Geneve';zip=90210}})
$a

# charger l'objet depuis un yaml
$b = [organiser]'.\5.object_definition.yml'

# charger tout les objets depuis un yaml
[organiser]::Load('.\5.object_definition.yml')