function New-ADIcon {
    param($ObjectClass, $Size) 

    $icon = 'question_circle'

    if ($ObjectClass -eq 'user') {
        $icon = 'user'
    }

    if ($ObjectClass -eq 'computer') {
        $icon = 'desktop'
    }

    if ($ObjectClass -eq 'group') {
        $icon = 'users'
    }

    New-UDIcon -Icon $icon -Size $Size
}