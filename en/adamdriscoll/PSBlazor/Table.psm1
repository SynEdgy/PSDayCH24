$Variables["Services"] = Get-Service

function ToggleState {
    param($context)
    $Message.Success($context.Name)
}