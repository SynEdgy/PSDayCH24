# PowerShell Day Lausanne, le 27 février 2024, Arnaud PETITJEAN (Start-Scripting)

## POWERSHELL UNIVERSAL : CODEZ VOTRE PORTAIL WEB EN POWERSHELL

### Liens utiles :
- [Site de mon organisme de formation](https://start-scripting.io)
- [Forum de la communauté PowerShell](https://powershell-scripting.com)
- [Ma Repository Github](https://github.com/apetitjean/PSDayLausanne2024)
- [Site de Ironman Software](https://ironmansoftware.com)
- [Documentation de PowerShell Universal](https://docs.powershelluniversal.com/)
- [Téléchargement de PowerShell Universal](https://ironmansoftware.com/powershell-universal/downloads) (choisir Windows MSI)
- [Pour obtenir une licence PSU d'essai 14 jours](https://ironmansoftware.com/trial/powershell-universal) 
- [Connexion à son instance PSU locale](http://localhost:5000)

### Quelques lignes de commandes utiles :
- Installer VSCode : `Winget install Microsoft.VisualStudioCode`
- Installer PowerShell 7 : `Winget install microsoft.powershell`

### Quelques bouts de code utiles :

```PowerShell
#####################################################################################
# Appel d'une API Rest avec la méthode Get et passage de token JWT
$token = 'Votre_JWT_Token_Ici'
$headers = @{
    'Authorization' = "Bearer $token"
}
 
$url = "https://example.com/api"
$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
######################################################################################
````
### Appel d'une API REST avec la méthode POST
```PowerShell
###################################################################################### 
# Appel d'une API REST avec la méthode POST
$url = "http://localhost:5000/localuser"
$body = @{
    'Username'    = 'PSDayLausanneUser2'
    'Description' = 'Follow along session'
} | ConvertTo-Json
$headers = @{
    "Content-Type" = "application/json"
}
$response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers
######################################################################################
