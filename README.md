# Lancer-NPC-Generator

This project is intended to make generating NPC characters for the Lancer RPG system fast and easy.

I am not a professional developer, or even a good one. Any improvement to this project would be appreciated.

To generate an NPC, simply run the Generate-LancerEnemies.ps1 script by right-clicking the file and selecting "Run with PowerShell". There are several easy to follow prompts that allow for quickly creating and modifying enemy classes. This does the legwork of tossing the NPC together.

Currently, NPC generation is restricted to Tier 1, and you must add optional systems manually. 

Enemy Classes are stored in Classes.json, Templates in Templates.json, and all Modules, Systems, and Weapons are in the Modules.json. Adding more Classes, Templates, or Modules is relatively straightforward, and shouldn't require too much hassle on the user's end.

The PowerShell scripts should run in both Windows and Linux (using PowerShell Core) and don't require importing to function. I plan to eventually make this into a real PowerShell module, or else port it to a different language that better supports the menu style UI I'm trying for.

You can save the generated NPC with the file name you wish. The script auto-appends .txt to the end so you won't have to. Saves all output under a sub-directory call 'outfiles' (which it automatically creates).

There is a Discord server dedicated to Lancer. You can join here: https://discord.gg/KnGuxSz

The Official Lancer RPG Twitter: https://twitter.com/Lancer_RPG

Tom's Twitter: https://twitter.com/orbitaldropkick

Miguel's Twitter: https://twitter.com/the_one_lopez

Tom has a Patreon, please go support him and read his comic: https://www.patreon.com/killsixbilliondemons

Miguel has a website full of good stories, give them a read: http://www.onlyonelopez.com/

DISCLAIMER:
I do not own the Lancer RPG, and have no rights to any of the original material. All credit for the Lancer RPG, including the system, PDF, and fictional universe belongs to Miguel Lopez (@the_one_lopez) and Tom Parkinson Morgan (@orbitaldropkick). This repository is published with the explicit permission of Tom, and can be replicated and modified by any user, so long as this and no resulting derivatives are sold for profit or any other reason.

Please support the official creators of this amazing product!
