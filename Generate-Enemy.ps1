<# 
    Date:    2018-09-22
    Version: 0.6.9
    Comment: Generates an enemy NPC for LANCER based on NPC Classes and Templates
#>
<# To do
1) Add tier modifications
2) Add the ability to select optional modules
3) Add the ability to add template modules
#>


# Asks the user if they would like to save $BaseClass to a file
function save_dialog {
    $user_input = Read-Host -Prompt "`nWould you like to save the generated NPC? [y/n]`n>"
    if ($user_input.ToLower().StartsWith("n")) {
        Write-Host "`nYou may wish to copy the generated NPC.`n"
        $BaseClass ; append_modules ; Start-Sleep -Seconds 1
        Read-Host "`nWhen you are done, input Return" | Out-Null
        Write-Host "Exitting"
        exit
    }
    if (!(Test-Path -Path .\outfiles)) {
        New-Item -Path .\outfiles -ItemType Directory | Out-Null
    }
    $user_input = Read-Host -Prompt "What would you like to name the file?`n>"
    $filename = $user_input + ".txt"
    $BaseClass > .\outfiles\$filename | Out-Null
    append_modules >> .\outfiles\$filename | Out-Null
    Write-Host "`nSaved the finished NPC to .\outfiles\$filename"
    exit
}

# Modifies the HP of $BaseClass
function modify_hp {
    if ([Int]$BaseClass.HP -ne 1) {
        if ($Template.'Bonus HP') {
            [Int]$BaseClass.HP += $Template.'Bonus HP'
            $Template.PsObject.Properties.Remove('Bonus HP')
        }
        elseif ($Template.'Max HP') {
            [Int]$BaseClass.HP = $Template.'Max HP'
            $Template.PsObject.Properties.Remove('Max HP')
        }
    }
}

# Modifies stats related to durability
function modify_durability {
    # For every stat that is related to durability
    foreach ($stat in 'Structure','Reactor Stress','Heat Capacity') {
        # If both $Template and $BaseClass have the stat, add them together
        if ($Template.$stat) {
            [Int]$BaseClass.$stat = $Template.$stat
            $Template.PsObject.Properties.Remove($stat)
        }
        elseif ($Template."Bonus $stat") {
            [Int]$BaseClass.$stat += $Template."Bonus $stat"
            $Template.PsObject.Properties.Remove("Bonus $stat")
        }
        elseif ($Template."No $stat") {
            $BaseClass.PsObject.Properties.Remove($stat)
            $Template.PsObject.Properties.Remove("No $stat")
        }
    }
}

# Adds the base class modules to final output
function append_modules {
    $modules = Get-Content -Raw -Path .\Modules.json | ConvertFrom-Json
    foreach ($mod in $BaseClass.Modules) {
        $mod
        foreach ($line in $modules.$mod) {
            $line
        }
        ""
    }
}

# Adds a template to the selected class
function add_template {
    # Print the available templates
    while (1) {
        Clear-Host
        Write-Host "`nPlease select one of the following templates, starting with Exclusives:`n"
        # Create an array to house the classes list and print options
        $i = 1
        foreach($item in $templates.PsObject.Properties.Name) {
            if ($templates.$item.Exclusive) {
                Write-Host "$item. $($templates.$item.Name) (Exclusive)"
            }
            else {
                Write-Host "$item. $($templates.$item.Name)"
            }
            $i++
        }
        # Get user input and select a valid template
        $user_input = Read-Host -Prompt "`nEnter template ID value`n>"
        if ($templates.$user_input) {
            $Template = $templates.$user_input
            # Remove the template so you can't apply the same one again
            $templates.PsObject.Properties.Remove($user_input)
            break
        }
        else {
            Write-Host "Please enter a valid ID." ; Start-Sleep -Seconds 2
            continue
        }
    }

    Write-Host "`nYou have selected the following template:`n"
    $Template ; Start-Sleep -Seconds 1
    $user_input = Read-Host -Prompt "`nWould you like to continue? [y/n]`n>"
    if ($user_input.ToLower().StartsWith("n")) {
        $user_input = Read-Host -Prompt "`nAre you sure? [y/n]`n>"
        if ($user_input.ToLower().StartsWith("n")) {
            save_dialog
        }
    }

    # Modify the $BaseClass.Tags value
    [System.Collections.ArrayList]$tags = $BaseClass.Tags + $Template.Name
    # Check if $Template is for a Ship or Vehicle
    if ('Vehicle','Ship' -contains $Template.Name) {
        $tags.Remove('Mech')
    }
    Add-Member -InputObject $BaseClass -MemberType NoteProperty -Name Tags -Value $tags -Force

    # Modify HP, Structure, and Reactor Stress
    modify_hp
    modify_durability

    # Add all of the new properties
    foreach ($p in Get-Member -InputObject $Template -MemberType Properties  | Sort-Object -Property Definition | Select-Object -Property Name | Sort-Object -Property Definition | Where-Object -NotMatch -Property "Name" -Value "Name") {
        Add-Member -InputObject $BaseClass -MemberType NoteProperty -Name $p.Name -Value $Template.$($p.Name) -WarningAction SilentlyContinue
    }
    # Print the newly modified class
    Write-Host "`nThis is the NPC after applying the $($Template.Name) template:`n"
    $BaseClass ; Start-Sleep -Seconds 1
    
    # Ask if the user would like to add another template
    $user_input = Read-Host -Prompt "`nWould you like to add another template? [y/n]`n>"
    if ($user_input.ToLower().StartsWith("n")) {
        save_dialog
    
    }
    elseif ($user_input.ToLower().StartsWith("y")) {
        # Remove other Exclusive templates
        if ($Template.Exclusive) {
            foreach ($t in $templates.PsObject.Properties.Name) {
                if ($Template.Exclusive -contains $templates.$t.Name) {
                    $template_index.Remove($t)
                    $templates.PsObject.Properties.Remove($t)
                }
            }
        }
        # Loops
        add_template
    }
    else {
        Write-Host "Unrecognized option. Please enter 'y' or 'n'."
    }
}

# Main script
Clear-Host
# Assemble the NPC classes and templates
$classes = Get-Content -Raw -Path .\Classes.json | ConvertFrom-Json
$templates = Get-Content -Raw -Path .\Templates.json | ConvertFrom-Json

# Loop to get the base class selection
while (1) {
    # Create an array to house the classes list and print options
    Write-Host "`nPlease select one of the following classes:`n"
    foreach($item in $classes.PsObject.Properties.Name) {
        Write-Host "$item. $($classes.$item.Name)"
    }
    # Get user selection
    $user_input = Read-Host -Prompt "`nEnter ID value`n>"
    if ($classes.$user_input) {
        $BaseClass = $classes.$user_input
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
    $user_input = Read-Host -Prompt "`nWould you like to add a template? [y/n]`n>"
    if ($user_input.ToLower().StartsWith("n")) {
        modify_durability
        save_dialog
    
    }
    elseif ($user_input.ToLower().StartsWith("y")) {
        # Create an index of available templates
        add_template
    }
    else {
        Write-Host "Unrecognized option. Please enter 'y' or 'n'."
    }
}

