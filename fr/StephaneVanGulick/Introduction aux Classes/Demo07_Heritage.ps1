Enum Couleur {
    Bleu
    Blanc
    Rouge
}

class maison {

    #Propriétés
    [Couleur]$Couleur
    [int]$Habitants

    #Constructeurs

    maison(){
        #Les constructeurs n'ont pas de d'indicateur de retour
        $this.Couleur = [Couleur]::Blanc
    }

    #Overload d'un constructeur
    maison([Couleur]$Col){
        $this.Couleur = $col
    }

    [int] GetNombreHabitants(){
        return $this.Habitants
    }

    #Methodes
    [Couleur] GetCouleur(){
        Return $this.Couleur
    }

    #Methodes
    [void] SetCouleur([Couleur]$Couleur){
        $this.Couleur = $Couleur
    }

    [String] SonneSonette(){
        Return "Brrr!"
    }

}

Class maisonSuisse : maison {
    
    
    maisonSuisse(){
        $this.SetCouleur([Couleur]::Rouge)
    }

    [String] SonneSonette(){
        Return "Clinkgelon Clinkgelon!"
    }

}

Class maisonAlsacienne : maison {
    
    [bool]$Colombages
    
    maisonAlsacienne(){
        $this.Colombages = $True
    }

    [String] SonneSonette(){
        Return "Ding - Dong!"
    }

}

$MS = [maisonSuisse]::New()
$MS.SonneSonette()

$MA = [maisonAlsacienne]::New()
$MA
$MA.SonneSonette()
