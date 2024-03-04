class maison {

    #Propriétés
    [string]$Couleur
    [int]$Habitants

    #Constructeurs

    maison() {
        #Les constructeurs n'ont pas de d'indicateur de retour
        $this.Couleur = "Rouge"
    }

    #Methodes

    [int] GetNombreHabitants() {
        return $this.Habitants
    }

    [String] GetCouleur() {
        Return $this.Couleur
    }

    #Methode qui ne retourne pas de valeur (VOID)
    [void] SetCouleur([String]$Couleur) {
        $this.Couleur = $Couleur
    }

}