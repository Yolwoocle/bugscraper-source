# Bugscraper changelog

This changelog includes changes related to the private beta. For access request, please ask me on [Discord](https://bugscraper.net/discord).


## 0.11.4
(*2026-06-11*)

### Gameplay
- ⭐ Removed Gun Orbs and replaced them with Life Orbs
    - Life Orbs break in a couple hits and will drop a heart that acts identically to the old heart.
    - To compensate, slightly increased Life Orb spawn chance
- ⭐ Removed Gazpacho upgrade. I plan on adding it back in a later update, but right now I do not have the time to properly balance it.
- ⭐ Adjusted Department 2 difficulty to make it fairer 
    - Spikes are slower, flash on spawn, and simplified some waves
- General difficulty adjustments

<details>
    <summary>SPOILERS (Boss 2)</summary>
    <ul>
        <li>Added lights to players in dept. 2 boss</li>
    </ul>
</details>

### Audio 
- Added and updated various sound effects across the game, courtesy of Martin Domergue, including audio for bosses, dept. 4 enemies, cutscenes, and UI elements.
- Increased default music volume from 50% to 75%

### UI & Misc
- Changed tutorial text
- Changes to credits and improved layout/formatting
- Slight changes to final cutscene

### Fixes 
- Fixed: Spanish padding issues
- Fixed: boss 2 would have spikes appearing at the edge of the cabin beginning of its fight

<details>
    <summary>SPOILERS (Final boss)</summary>
    <ul>
        <li>Fixed: ghost players could stomp on final boss minions</li>
    </ul>
</details>


## 0.11.3
- Fixed: electric arcs and vines were not properly removed on some waves

## 0.11.2
Adds some improvements and fixes a couple of issues including a crash related to the Polish language. Sorry about that. 

- Life drops are now more biased the more time passes without one dropping
- Increased despawn time for gun orbs
- Small update to dept 4 background sprite 
- Waves that used to kill enemies now just remove them
- Player footstep SFX now fade out in some cutscenes
- Added landing SFX to projectiles
- Changed jump icon
<details>
    <summary>SPOILERS (Waves 40-60)</summary>
    <ul>
        <li>Reduced Metal Mosquito HP from 10 to 5</li>
    </ul>
</details>
<details>
    <summary>SPOILERS (Final boss)</summary>
    <ul>
        <li>Final boss now removes all his minions on death</li>
    </ul>
</details>


### Fixes
- Fixed crash when using PL language
- Fixed: boomshroom & flying nest flash SFX would continue playing in pause menu
- Fixed: No life would drop if, for example, you had 2/4 normal hearts and 2 extra hearts
<details>
    <summary>SPOILERS (Post final boss)</summary>
    <ul>
        <li>Fixed background issue in final area</li>
        <li>Fixed missing collision on left-side building in final area</li>
    </ul>
</details>


## 0.11.1
- Fixed issue where the boss from world 2 could spawn on wave 73. Sorry about that...

## 0.11

- ⭐ New upgrade: Gazpacho
    - After taking damage, if you quickly fight back, you can regain 1 ❤
- ⭐ Changed Espresso upgrade to be based on whether you're in a combo rather than on a number of waves
- Coconut Water upgrade now also charges the gun when reloading
- Tea hearts are now shown next to the heart bar
- Reduced Spiked Fly HP from 5 to 2.5
- More SFX integration

<details>
    <summary>SPOILERS (Waves 60-80)</summary>
    <ul>
        <li>Reduced Cloud Storm (placeholder name) zone attack time</li>
        <li>Reworked difficulty and pacing of Dept. 4</li>
        <li>Golden Beetles no longer rotate as much after activated</li>
        <li>Changed Dropper (placeholder name) enemy sprite</li>
        <li>Fixed weird centipede spawning</li>
        <li>Fixed: Dropper (placeholder name) enemy no longer goes back to telegraphing state every time it's damaged after being damaged once</li>
    </ul>
</details>

<details>
    <summary>SPOILERS (Waves 80+)</summary>
    <ul>
        <li>Basement rocket cutscene particle color fix</li>
        <li>Reworked final boss (2nd phase & minions)</li>
        <li>Added telegraphing to final boss hopping attack</li>
        <li>Final cutscene changes</li>
    </ul>
</details>

### Fixes
- Fixed: Nintendo Switch controller button prompts A/B and X/Y were inverted
- Fixed: completing the game or the demo would not apply XP
- Minor change to splash image 

### Misc 
- Added some props to tutorial

### Technical 
- Multiline support to cafeteria text
- Added english fallback text by default
- New reward menu now supports line breaks



## 0.10.1

- Fixed Steam API integration on macOS and Linux, courtesy of Alexis
- Fixed: constant sounds (e.g. fly's buzzing sound, player's wall sliding sound) were not affected by "SFX volume" option
- Added spatial audio for constant sounds
- Added SFX to ground floor props: big plants and construction zone sign
- Added XP tick SFX
- XP rewards are now re-granted on launch (which might be useful, say, if the order of rewards is changed in the future)
- Fixed issue where "all upgrades" and "all characters" achievements would not be re-granted on launch


## 0.10

Big but not very exciting update, sorry! The biggest additions are achievments and stats. But it's mostly just a ton of bug fixes, QOL additions and polishing.

This is because I've been focusing on getting things done to release a new demo on Steam soon. 

Please not that the Steam integration doesn't work on macOS and Linux yet, so you won't get achievements for now. We're working on fixing that for the next update.

Thank you for your patience! :)

### General
- ⭐ Achievements! There are 12 of them currently, you can obtain them in-game and through Steam too.
- ⭐ Statistics screen, available through the pause menu
- Increased despawn time for guns and gun orbs
- Section 1
    - Mr Dung now has a fainted effect after death
    - Mr Dung's final death ejected animation now depends on his x position
- Section 2
    - Made Stabees slightly larger
    - Changed color of timed spikes warning
- Section 4
    - Cloud Storm Zone enemy (placeholder name) wait timer now starts at a random value after spawn
    - Vines now render in front of everything
    - Extended wave 70 spiral vines to be visible outside of the cabin too
    - Added boss intro to Boss 4
    - Added death animation to Boss 4
    - Reduced Boss 4's HP
- Section 5
    - Updated final few waves to match W4's enemies
    - Final boss polish
        - Second-to-last wave before final boss contains 2x Heart jar 
        - Final boss intro and death cutscene
        - Win screen
- Input 
    - Added Y as confirm button on controllers
- Multiplayer 
    - Decreased amount of waves until respawn in multiplayer from 5 to 3
    - Made players cocoon respawning more obvious
    - Cocoons are now rendered in front of all actors except players
    - All players are now respawned at wave 99
- Misc 
    - Changed: Heart drops now go through solid collisions
    - Steam API Integration
    - Cutscenes fixes (made some unpausable + fixed minor final cutscene issues)
    - Removed shadows in tutorial


### UI
- Improved readability of text menu item player indicator
- Added animations to menus when they're set
- Moved input options down in options menu
- New character screen now shows source of guest characters
- Added "feedback" button to language selection menu

 
### Audio
- New sounds courtesy of Martin:
    - Achievemnts xp bar tick
    - Boss 3
    - Motherboard & Pendulum sounds
    - Grasshopper SFX
    - Metal fly
    - Chipper
    - Big Chippers
    - Golden Beetle
    - Nex XP reward SFX
- W5 music (placeholder)
- Chipper SFX is a bit less loud
- Synced death sound with visuals


### Localization
- Updated the following localizations:
    - ⭐ New language: Japanese, courtesy of Sora and Clément Macheret
    - Brazilian Portuguese, courtesy of Nicole Sanches, kiwisky and parinamais
    - Polish, courtesy of Jakub Piłasiewicz
    - Spanish, courtesy of Alejandro Alzate Sánchez 
    - French
- Removed Simplified Chinese localization for now
- Added basic language selection screen on first startup


### Fixes
- Fixed: Issue where vines would not be deleted before Boss 4
- Fixed: Multiple Centipedes could spawn in a later W4 wave
- Fixed: Dying while a heart was attracted towards a player would cause that heart to jitter until the end of the game
- Fixed: Exit sign easter egg camera issue
- Fixed: Breakable actors now spawn state changing particles correctly
- Fixed: Screenshake would still be updated while game was paused
- Fixed: Background would not scroll after final boss enter cutscene
- Fixed: Weird crash related to CloudStormZone enemies AI management
- Fixed: Game would crash if steamworks API was not correctly loaded
- Fixed: Explosions should always insta-kill all enemies
- Fixed: Ghost players can no longer shoot when no player is alive (like in GAME_STATE_DYING state)
- Fixed: Cocoons will no longer spawn players if the game is in "GAME_STATE_DYING" state
- Fixed: Golden beetles would reset explosion timer after being shot
- Fixed: Properly centered menus
- Fixed: You could move at the beginning of ceo_escape_w5 cutscene
- Fixed: chippers walk sound could stay after their death
- Fixed: Disabled debug mode to releases
- Fixed: Removed loot from final vending machine


### Optimizations
- Optimized loading of some sounds
- Backported the game from LÖVE 12 to LÖVE 11.5



## 0.9.3
(*2026-02-02*)

- **Fixed**: wrong texture was given to Mr. Dung's flying balls


## 0.9.2
(*2026-01-30*)

New update! Please give me as much feedback as possible regarding department 4. I'm still working on reworking boss 2, please give it my sweet time. 🙇‍♂️

- ⭐ **Complete rework of dept 4** (||the gardens||)
    - The ||"Cloud Storm"|| enemy (placeholder name) now works differently
    - New enemy: ||Golden Beetles. After damaged, will run around before exploding||
    - Increased difficulty and design of the wave (except the boss)
    - Tweaked boss 4 tweaks to make it less punishing (still hard, though)
- ⭐ **New music!!** Courtesy of @okko_san.
    - Reworked boss 1 music
    - New music for boss 2
    - New music for boss 4
    - New music for dept 4
    - Reworked cafeteria music
- ⭐ **Added**: Roaring Knight TV slide, coutersy of @linkylorelei. RAAAAAHHH!!!!
- **Added**: New cocoon and revive sound effects
- **Changed**: Added white outlines around players and a counter in the ground floor elevator door
- **Changed**: Diminished HP & screenshake of Heart Jars
- **Added**: Added a 2 frame delay for adding new players after leaving or joining the game
- **Changed**: New splash screen
- **Changed**: Boss 3 now stops the music after beaten

### Fixes 
- **Fixed**: Music would not change in cafeterias after selecting an upgrade
- **Fixed**: Stomping an enemy while holding jump a few frames after landing on the floor would shoot the player upwards
- **Fixed**: You can no longer assign the same button for different UI actions
- **Fixed**: Players in a shop could move while a CEO cutscene was playing
- **Fixed**: Controller users could not join if a keyboard user was present in the game
- **Optimized**: Slight optimisation to the game's 3D renderer


## 0.9.1
(*2026-01-17*)

- **Added**: Heart jars in cafeterias, which give a heart to every player in the game
- **Fixed**: Boomshrooms would not count into the combo counter
- **Added**: Added for now empty boss intro for boss 4
- **Changed**: Slightly reduced the amount of Chippers in wave 41
- **Changed**: Tweaks to boss 3 (the Webmaster)
    - Slightly increased the spawn delay for Chipper minions
    - Increased the Chipper minion phase's duration
    - All Chipper minions are killed when the boss is killed
    - Increased the time interval between button spawns 
    - Buttons now eject the player down & gives them invincibility
    - Made the pendulum spawning animation longer during the 1st phase of the boss
    - Buttons spawn faster immediately after the middle transition animation
- **Removed**: Removed the pink "Boba" NPC
- **Fixed**: Fixed issues related to Linux, courtesy of Alexis Belmonte

**Minor fixes:**
- Big chippers no longer have the scaling anim
- Small tweak to pendulum animation


## 0.9
(*2026-01-09*)

I added a "⭐" emoji next to highlights to make this changelog easier to read.

### Gameplay 
- ⭐ **Added**: New character, Amb! She's a shy harworking bug, usually messing around in the Server Room.
- ⭐ **Added**: New enemy, the 'Dropper' (placeholder name): spawns in dept. 4, flies around randomly and drops down as soon as it is damaged, spawning 4 projectiles when hitting the floor  
- ⭐ **Added**: New Boss for dept 4! Please not that this is still a WIP
- ⭐ **Added**: Last area for the game, including the final boss. I will not spoil it... Please not that this is still a WIP
- ⭐ **Changed**: Heart loot probability now depends on the health of the player with the least health: they depend linearly (full health = x0 probability, half health = x1, low health = close to x2)
- ⭐ **Added**: Added NPCs in cafeterias! They don't do anything, they're just here to chill.
- **Changed**: Ajusted the difficulty of dept. 3
- **Changed**: Slightly buffed ghosts' puff attack
- **Changed**: Made bullets' hitboxes slightly bigger
- **Changed**: Guns are now instantly collected when you press the 'interact' button

### Visuals
- **Changed**: Improved & polished Webmaster boss
- **Added**: New "Buglatro" TV slide by 8lueskii 
- **Added**: Added warning signs before spikes in dept. 2 appear
- **Changed**: Various polishes to the tutorial 
- **Changed**: Various improvements to the post wave 80 rocket section
- **Changed**: Visual improvements to the CEO's office and its associated cutscene
- **Changed**: Various polishes to Her Majesty, including a new crowd that reacts to the fight  
- **Changed**: Minor graphical improvements to cafeterias
- **Changed**: Larva projectiles coming from flying spawners (placeholder name) are now visually spiky  
- **Changed**: Minor graphical improvement to the title that plays when you enter a new department
- **Changed**: Added a particle to Rollopods when they notice you
- **Changed**: Grahpical changes to dept. 4's visuals
- **Changed**: Grahpical changes to poison and stink bugs, which are now yellow, to make them more consistent 
- **Changed**: Small change to the ground floor sprite

### UI
- **Changed**: Moved upgrades UI position to the top right
- **Changed**: Changed the UI layout of upgrades to be vertical
- **Changed**: The timer now display in front of the UI when paused
- **Changed**: Added 'Max combo' stat to the Game Over screen
- **Changed**: Removed credits from pause menu (for now)
- **Changed**: Slight tweaks to various UI elements
- **Removed**: Removed convention mode from options

### Sound
- ⭐ **Added**: New music! Including pause music for dept 2 and bosses, and various changes to the music of the game (Including Dept. 1 & Dept. 3). Courtesy of OLX.
- ⭐ **Added/Changed**: New sounds! Courtesy of Martin Domergue
    - Various enemy sounds including honeypot ants & grasshoppers
    - Weapon pick up sounds
    - Improved gun sounds
    - Mr Dung sounds
    - Her Majesty sounds
    - Spike sounds
    - New upgrade sounds
    - Various cutscene sounds
    - Many more other sound improvements and additions 
- ⭐ **Added**: Spatial audio! I recommend using headphones to fully enjoy it.
- ⭐**Added**: Ambiance sounds! Can be disabled in options.
- **Added**: Added intros to music loops: music will now have an intro before their main loop
- **Changed**: Music will now play back to its previous point when exiting a cafeteria

### Fixes
- **Fixed**: Fixed issue where you could spawn multiple players
- **Fixed**: Fixed issue where the Pea Gun could duplicate in the tutorial
- **Fixed**: Fixed issue where player could slightly clip through the elevator door when exiting cafeterias 
- **Fixed**: Fixed issue where Bulb Buddies would sometimes spawn outside of the elevator door
- **Fixed**: Fixed issue where Rollopods could sometimes be pushed around after rolling
- **Fixed**: Wall jumping to the rocket cutscene would not remove the low stamina beep
- **Fixed**: Fixed bug related to the music not fading in correctly when quick restarting the game
- **Fixed**: Removing an action from "join game" with a certain input type (i.e. keyboard or controller) would remove actions from all other input types 
- **Fixed**: Fixed issue where you could assign 0 buttons to "join game"
- **Fixed**: Fixed padding issue with Spanish 
- **Fixed**: Fixed bug where vines weren't removed after wave 80
- **Fixed**: Fixed minor graphical issue with dept. 3's falling grid animation

### Localization 
- **Changed**: Minor changes to some localized text
- **Changed**: The game now takes into account all user locales
- **Changed**: Added a menu padding parameter to locales
- **Changed**: Updated Spanish translations, courtesy of Alejandro Alzate Sánchez
- **Changed**: Some updates to Portugese Brazilian translations, courtesy of itzKiwiSky

### Misc
- **Added**: Added a new CEO escape cutscene after dept. 3
- **Added**: Added some gamepad vibrations in menus
- **Changed**: The game will no longer boot if bugscraper.png is not present, courtesy of Alejandro Alzate Sánchez

And many other various optimizations, improvements and fixes.


## 0.8.1
(*2025-10-01*)

- **Fix**: Fixed issue where vines (placeholder name) would not deal any damage 
- **Fix**: Fixed issue where Chippers would not play their telegraph sound  


## 0.8
(*2025-09-27*)

### Highlights
- 🔊 **Sound design** has been completely reworked from scratch, thanks to the work of the new sound designer in the team, Martin Domergue!! Please note that this is still a work in progress, and do not hesitate to send feedback and criticism, it is highly appreciated.
- 🪴 **New 4th department!** The Gardens are the Bugscraper's highest area, a luxurious place where reside the company's highest ranked executives. Please note that it is still a work in progress and a lot of things are still placeholders.
- 🔘 **New "interact" button!** This button is used to open up the new cafeteria interface, to exit the game, or to collect guns. Unfortunately this will reset your custom remappings, I'm sorry :(

### Gameplay
- **Change**: Sound design has been completely reworked from scratch, thanks to the work of the new sound designer in the team, Martin Domergue
- **Added**: New department 4. The Gardens are the Bugscraper's highest area, a luxurious place where reside the company's highest ranked executives. Please note that it is still a work in progress and a lot of things are still placeholders.
- **Added**: Added a "interact" button, mapped by default to "Z" on keyboard and the right action button (Nintendo A, Xbox B, Playstation circle) on controllers. This addition also changes the default mappings and removes the "exit game" action. Unfortunately this will reset any custom remappings you might have had. 
- **Change**: The exit sign now uses the interact button
- **Change**: You now need to use the interact button to collect guns
- **Added**: A new interface for the cafeteria upgrades has been added, and the previous upgrade jars have been removed.
- **Added**: Added two small animations on floors 20, 40. I'll let you discover them... 
- **Added**: Boss bars!
- **Change**: Various changes to combos. They are easier to start and keep, and the visuals have received a glow-up
- **Change**: In co-op, respawn cocoons now appear at every cafeteria
- **Change**: Camera now pans to the left after opening the door
- **Change**: Slight adjustments to dept. 2 waves to make them feel less punishing 
- **Change**: Slightly increased wall sliding stamina limit
- **Change**: Minor tweaks to Her Majesty boss
- **Change**: Made guns slightly more pleasant to use by making bullets spawn from the base of guns
- **Added**: Added a new easter egg 👀 

### Graphics
- **Change**: Weapons and hearts will now always render in front of enemies
- **Change**: Added visual effect to ghosts' spinning
- **Change**: Minor tweak to splash screen graphic
- **Change**: Slight improvements to some backgrounds
- **Change**: The city background display lower down the higher up you are 
- **Change**: The currently active user is shown in menus in co-op 
- **Added**: Added a few TV slides
- Various other minor graphical changes 

### Menus
- **Added**: Added "SFX Volume" option
- **Change**: You can now use keyboard inputs to navigate menus even if no keyboard player joined the game
- **Added**: Added simplified chinese localisation. Right now it's all machine-translated but I do plan on adding manual translations later on.
- **Change**: Renamed "retry" to "return to ground floor"
- **Change**: Changed feedback menu
- **Change**: Buttons are no longer selectable during the game over animation

### Fixes
- **Fix**: Fixed bug where the 3D graphics of the Comball would not appear at the right location while in the elevator door
- **Fix**: Fixed minor visual artifact that sometimes happened when enemies spawn from the elevator door
- **Fix**: Fixed issue where splash screen would not be correctly cut if width of window is very large
- **Fix**: Fixed issue where the music would play for a single frame when starting the game if the music volume was set to 0 
- **Fix**: Fixed issue where the window could be completely dark if scaled down while pixel scale was set to "max whole" 
- **Fix**: Fixed issue where you could not start a game if there was no player 1
- **Fix**: Fixed issue where in co-op, you would not respawn with all your hearts if you had the milk upgrade
- **Fix**: Fixed issue where the "bullet lightness" option would affect non-player bullets
- **Fix**: Fixed issue where disconnecting your controller while in a game and pressing "continue anyway" could sometimes softlock you 
- **Fix**: Partially fixed issue where you could not press certain buttons during a time freeze 
- **Fix**: Fixed issue where "return to ground floor" would not return players to the ground floor in the tutorial
- **Fix**: Fixed issue where Mr. Dung couldn't be damaged when bunny hopping
- **Fix**: Fixed minor graphical issue where the timer & cinematic bar would clash sometimes


## 0.7.2
(*2025-07-04*)

- **Fix**: Fixed issue where a certain easter egg would crash the game
- **Fix**: Removed dept. 4 (planned for a future update) 
- **Fix**: Linux version is now correctly supported on Steam


## 0.7.1
(*2025-07-03*)

- **Fix**: Fixed issue where enemies would not drop any loot


## 0.7
(*2025-07-01*)

New update!!! Please report any issues you run into!

This is a small update with some of the content that I've been working on. From now on, I will limit the amount of new content I add (apart from the upcoming dept. 4) as I start heading towards the release of the game, hopefully towards the end of August (no guarantees, though). Sorry for the lack of news, I had a lot in my life and didn't want to rush things out. Please be patient, thank you for waiting. :)

I'm sorry to say that this update will reset your progress, I've made it so that it doesn't boot up the whole tutorial animation, but as I said last time I'll work on a more permanent solution in the future.

- **Added**: Wall climbing now uses a stamina system: jumping and sliding uses up stamina, and when you run out of it, you will fall 
- **Added**: Energy Drink upgrade: combo meter decreases more slowly
- **Added**: In co-op, you will now become a ghost after dying. Ghosts can shoot small bursts of bullets that deal a little damage. Players can be respawned from ghosts by breaking cocoons that will appear a few waves later
- **Added**: New sounds from the new sound designer in the team, Verbaudet! More sounds are to come in future updates!
- **Change**: Respawned players will now appear with full health, however cocoons appear more rarely  
- **Change**: Espresso now lasts for 20 floors (prev. 10)
- **Change**: Hot chocolate now affects natural recharging (the recharging that happens after waiting for a few seconds)
- **Change**: Beelets from dept. 2 no longer appear spiky when angered
- **Change**: Reskinned and polished the Stabee enemy, from dept. 2
- **Change**: Background fan in dept. 2 now spins 
- **Change**: Polished up dept. 3 cabin background
- **Change**: Added a cooldown for cloud storm enemy (temporary name)
- **Change**: Improvements in the player animations, in particular, the damage and invincibility animations
- **Fix**: Partial fix to an issue where some enemies like boomshrooms, stink bugs' clouds, and larvae spawned from projectiles, would clip into the ground and teleport. This might still happen, just hopefully to a lesser degree
- **Fix**: Fixed visual bugs related to TV presentation


## 0.6 
(*2025-03-22*)

First Steam beta release (after a year of development, never too late..!) If you had the game before, I'm sorry to say that this release will reset your progress (skins & upgrades). I'll work on a more permanent solution in the future but right now this the best way I found to avoid incompatibility bugs. Be expected for this to happen often in a game still in beta. :P

- **Added**: Option to replay the tutorial in the settings 
- **Added**: You can press down to go through platforms
- **Change**: Various improvements to the tutorial
- **Change**: Improved flying nests (temporary name): now only shoot in defined directions and will flash before exploding after being killed
- **Change**: You now have more upgrades when first starting the game to avoid cases where upgrade jars would spawn empty 
- **Change**: Honeypot footballs (temporary name) explode faster so it doesn't ruin your combo
- **Change**: You can no longer attack dept. 2 bee boss with bullets
- **Change**: Increased opacity for Stink bug poison cloud
- **Change**: Espresso upgrade now lasts for 10 floors instead of 1 minute
- **Fix**: Quick restarting no longer has that small “intro”
- **Fix**: Drill bees (temporary name) now give some fury when exploding
- **Fix**: Ground floor music no longer plays when reviving a player 


## Older versions
I didn't write changelogs for older versions, but you can probably access these versions at [yolwoocle.itch.io/bugscraper](https://yolwoocle.itch.io/bugscraper), or look through the GitHub commit history ([github.com/yolwoocle/bugscraper](https://github.com/yolwoocle/bugscraper)) and look for the changes yourself.
