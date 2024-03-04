. C:\Users\Stephane\OneDrive\PARA\AREAS\UserGroups\PSSuisse\Introduction aux classes\Demo07_Heritage.ps1
Describe '[maison]-[Constructors]'{

It '[maison]-[Constructor] - Parameterless should Not Throw' {

    # -- Arrange

    # -- Act

    # -- Assert

    {[maison]::New()} | Should Not Throw 

}# end of it block


It '[maison]-[Constructor]([Couleur]Col) should Not Throw' {

    # -- Arrange


    [Couleur]$Col=''

    # -- Act

    # -- Assert

    {[maison]::New($Col)} | Should Not Throw 

}# end of it block


}# end of Describe block
Describe '[maisonSuisse]-[Constructors]'{

    It '[maisonSuisse]-[Constructor] - Parameterless should Not Throw' {

    # -- Arrange

    # -- Act

    # -- Assert

        {[maisonSuisse]::New()} | Should Not Throw 

    }# end of it block


}# end of Describe block
Describe '[maisonAlsacienne]-[Constructors]'{

It '[maisonAlsacienne]-[Constructor] - Parameterless should Not Throw' {

# -- Arrange

# -- Act

# -- Assert

{[maisonAlsacienne]::New()} | Should Not Throw 

}# end of it block


}# end of Describe block
Describe '[maisonAlsacienne]-[Methods]'{

#Public Method
It '[maisonAlsacienne] --> SonneSonette() : [String] - should Not Throw' {

# -- Arrange

# -- Act

$Instance = [maisonAlsacienne]::New()

# -- Assert

{$Instance.SonneSonette()} | Should Not Throw

} #End It Block

#Public Method
It '[maisonAlsacienne] --> SonneSonette() : [String] - should return type [String]' {

# -- Arrange

# -- Act

$Instance = [maisonAlsacienne]::New()
# -- Assert

($Instance.SonneSonette()).GetType().Name | should be String

} #End It Block

}#EndDescribeBlock

