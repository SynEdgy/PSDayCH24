function ClickMe {
    param($EventArgs)

    Write-Host ($EventArgs | Out-String)

    $Message.Success($EventArgs.ScreenX.ToString())
}