<# 
    Date:    2018-09-22
    Version: 0.6.3
    Comment: Generates an enemy NPC for LANCER based on NPC Classes and Templates
#>
<# To do
1) Add the ability to attach multiple (non-exclusive) templates
    a) Needs to replace tags where necessary (eg. Vehicle template)
2) Add tier modifications
3) Add the ability to select optional modules
4) Add the ability to add template modules
#>


# Asks the user if they would like to save $BaseClass to a file
function saveDialog {
    $userInput = Read-Host -Prompt "`nWould you like to save the generated NPC? [y/n]`n>"
    if ($userInput.ToLower().StartsWith("n")) {
        Write-Host "`nYou may wish to copy the generated NPC.`n"
        $BaseClass ; addModules ; Start-Sleep -Seconds 1
        Read-Host "`nWhen you are done, input Return" | Out-Null
        Write-Host "Exitting"
        exit
    }
    if (!(Test-Path -Path .\outfiles)) {
        New-Item -Path .\outfiles -ItemType Directory | Out-Null
    }
    $userInput = Read-Host -Prompt "What would you like to name the file?`n>"
    $filename = $userInput + ".txt"
    $BaseClass > .\outfiles\$filename | Out-Null
    addModules >> .\outfiles\$filename | Out-Null
    Write-Host "`nSaved the finished NPC to .\outfiles\$filename"
    exit
}

# Modifies the HP of $BaseClass
function modHP {
    if ($Template.'Bonus HP') {
        [Int]$BaseClass.HP += $Template.'Bonus HP'
        $Template.PsObject.Properties.Remove('Bonus HP')
    }
    elseif ($Template.'Max HP') {
        [Int]$BaseClass.HP = $Template.'Max HP'
        $Template.PsObject.Properties.Remove('Max HP')
    }
}

# Modifies stats related to durability
function modDurability {
    $durability = @('Structure','Reactor Stress')
    foreach ($stat in $durability) {
        if ($Template.$stat -and !$BaseClass.$stat) {
            Add-Member -InputObject $BaseClass -MemberType NoteProperty -Name $stat -Value $Template.$stat
            $Template.PsObject.Properties.Remove($stat)
        }
        elseif ($Template.$stat -and $BaseClass.$stat) {
            [Int]$BaseClass.$stat += $Template.$stat
            $Template.PsObject.Properties.Remove($stat)
        }
        elseif (!$BaseClass.$stat) {
            Add-Member -InputObject $BaseClass -MemberType NoteProperty -Name $stat -Value "1"
        }
    }
}

# Adds the base class modules to final output
function addModules {
    $modules = Get-Content -Raw -Path .\Modules.json | ConvertFrom-Json
    foreach ($mod in $BaseClass.Modules) {
        $mod
        foreach ($prop in $modules.$mod) {
            $prop
        }
        ""
    }
}

# Add a template to the class
function addTemplate {
    # Print the available templates
    while (1) {
        Clear-Host
        Write-Host "`nPlease select one of the following templates:`n"
        foreach ($t in $templates.Index.PsObject.Properties) {
            Write-Host $t.Name"`b."$t.Value
        }
        # Get user input
        $userInput = Read-Host -Prompt "`nEnter ID value`n>"
        if ($templates.$userInput) {
            $Template = $templates.$userInput
            # Remove the template so you can't apply the same one again
            $templates.PsObject.Properties.Remove($userinput)
            $templates.Index.PsObject.Properties.Remove($userinput)
            break
        }
        else {
            Write-Host "Please enter a valid ID." ; Start-Sleep -Seconds 2
            continue
        }
    }

    Write-Host "`nYou have selected the following template:`n"
    $Template ; Start-Sleep -Seconds 1
    $userInput = Read-Host -Prompt "`nWould you like to continue? [y/n]`n>"
    if ($userInput.ToLower().StartsWith("n")) {
        $userInput = Read-Host -Prompt "`nAre you sure? [y/n]`n>"
        if ($userInput.ToLower().StartsWith("n")) {
            saveDialog
        }
    }

    # Modify the $BaseClass.Tags value
    $tags = $BaseClass.Tags + $Template.Name
    Add-Member -InputObject $BaseClass -MemberType NoteProperty -Name Tags -Value $tags -Force

    # Modify HP, Structure, and Reactor Stress
    modHP
    modDurability

    # Add all of the new properties
    foreach ($p in Get-Member -InputObject $Template -MemberType Properties  | Sort-Object -Property Definition | Select-Object -Property Name | Sort-Object -Property Definition | Where-Object -NotMatch -Property "Name" -Value "Name") {
        Add-Member -InputObject $BaseClass -MemberType NoteProperty -Name $p.Name -Value $Template.$($p.Name) -WarningAction SilentlyContinue
    }
    # Print the newly modified class
    Write-Host "`nThis is the NPC after applying the $($Template.Name) template:`n"
    $BaseClass ; Start-Sleep -Seconds 1
    
    # Ask if the user would like to add another template
    $userInput = Read-Host -Prompt "`nWould you like to add another template? [y/n]`n>"
    if ($userInput.ToLower().StartsWith("n")) {
        saveDialog
    }
    elseif ($userInput.ToLower().StartsWith("y")) {
        # Remove other Exclusive templates
        if ($Template.Exclusive) {
            foreach ($t in $templates.PsObject.Properties.Name) {
                if ($templates.$t.Exclusive) {
                    $templates.PsObject.Properties.Remove($t)
                    $templates.Index.PsObject.Properties.Remove($t)
                }
            }
        }
        # Loop
        addTemplate
    }
    else {
        Write-Host "Unrecognized option. Please enter 'y' or 'n'."
    }
}

# Main
Clear-Host
# Assemble the base class of the NPC
$classes = Get-Content -Raw -Path .\Classes.json | ConvertFrom-Json
$templates = Get-Content -Raw -Path .\Templates.json | ConvertFrom-Json

# Loop to get the base class selection
while (1) {
    # Print options to the user
    Write-Host "`nPlease select one of the following as the base NPC class:`n"
    foreach ($c in $classes.Index.PsObject.Properties) {
        Write-Host $c.Name"`b." $c.Value
    }
    # Get user selection
    $userInput = Read-Host -Prompt "`nEnter ID value`n>"
    if ($classes.$userInput) {
        $BaseClass = $classes.$userInput
        break
    }
    else {
        Write-Host "Please enter a valid ID." ; Start-Sleep -Seconds 2
        continue
    }
}
Write-Host "`nYou have selected the following base class:"
$BaseClass ; Start-Sleep -Seconds 1

# Ask if user would like to add a template, otherwise exit
while(1) {
    $userInput = Read-Host -Prompt "`nWould you like to add a template? [y/n]`n>"
    if ($userInput.ToLower().StartsWith("n")) {
        modDurability
        saveDialog
    }
    elseif ($userInput.ToLower().StartsWith("y")) {
        addTemplate
    }
    else {
        Write-Host "Unrecognized option. Please enter 'y' or 'n'."
    }
}

