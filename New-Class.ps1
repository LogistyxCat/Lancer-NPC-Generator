<#
    Version: 0.6.9
    Description: Used to add classes to the Classes.json file
#>

$properties = "Name",
"Hull",
"Agility",
"Systems",
"Engineering",
"HP",
"Structure",
"Evasion",
"E-Defense",
"Heat Capacity",
"Reactor Stress",
"Armor",
"Speed",
"Sensors",
"Size"
$tags = @("Mech")
$modules = @()

$new_class = New-Object psobject
Clear-Host

foreach ($p in $properties) {
    if ("Structure","Reactor Stress" -contains $p) {
        Add-Member -InputObject $new_class -MemberType NoteProperty -Name $p -Value 1
    }
    else {
        $value = Read-Host "$p"
        Add-Member -InputObject $new_class -MemberType NoteProperty -Name $p -Value $value
    }
}
Add-Member -InputObject $new_class -MemberType NoteProperty -Name Tags -Value $tags
Add-Member -InputObject $new_class -MemberType NoteProperty -Name Tags -Value $modules

$new_class
$i = Read-Host "Is this correct? [y/n]"
if ($i.ToLower().StartsWith("n")) { Write-Host "Quitting" ; exit }

$classFile = ".\Classes.json"
$classes = Get-Content -Raw -Path $classFile | ConvertFrom-Json
$length = Get-Member -InputObject $classes -MemberType Properties | Measure-Object | Select-Object -ExpandProperty Count

Add-Member -InputObject $classes -MemberType NoteProperty -Name $length -Value $new_class

Write-Host "Creating a backup of Classes.json"
Copy-Item -Path $classFile -Destination .\Classes.bkp.json
$classes | ConvertTo-Json | Out-File ".\Classes.json"
