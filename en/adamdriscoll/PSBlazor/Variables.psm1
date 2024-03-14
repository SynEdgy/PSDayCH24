$Variables["MyVariable"] = "Hello World"

function WhatIsMyVariable() {
    $Message.Success($Variables["MyVariable"])
}

function UpdateVariable() {
    $Variables["MyVariable"] = "Hello World Updated"
    $Message.Success("Variable Updated")
}