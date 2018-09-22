<#
    Version: 0.4 (Incompatible)
    Description: Used to add classes to the Classes.json file
#>

$properties = "Name",
"Hull",
"Agility",
"Systems",
"Engineering",
"HP",
"Evasion",
"E-Defense",
"Heat Capacity",
"Armor",
"Speed",
"Sensors",
"Size"
$tags = @("Mech")

$newClass = New-Object psobject
Clear-Host

foreach ($p in $properties) {
    $value = Read-Host "$p"
    Add-Member -InputObject $newClass -MemberType NoteProperty -Name $p -Value $value
}
Add-Member -InputObject $newClass -MemberType NoteProperty -Name Tags -Value $tags

$newClass
$i = Read-Host "Is this correct? [y/n]"
if ($i.ToLower().StartsWith("n")) { Write-Host "Quitting";exit }

$classFile = ".\Classes.temp.json"
$classes = Get-Content -Raw -Path $classFile | ConvertFrom-Json
$length = Get-Member -InputObject $classes -MemberType Properties | Measure-Object | Select-Object -ExpandProperty Count

Add-Member -InputObject $classes -MemberType NoteProperty -Name $length -Value $newClass
Add-Member -InputObject $classes.Index -MemberType NoteProperty -Name $length -Value $newClass.Name

$classes | ConvertTo-Json | Out-File ".\Classes.temp.json"