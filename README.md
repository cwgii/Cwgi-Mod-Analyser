cwgi mod analyser
Clean PowerShell GUI tool to scan Minecraft mods and flag possible cheat clients, hidden libraries, launcher bypasses, and obfuscated jars.

Installation
Run it straight from GitHub:

powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/cwgii/Cwgi-Mod-Analyser/main/Miller-Mod-Anylser.ps1')"
Or run the script locally if you already downloaded it:

powershell -ExecutionPolicy Bypass -File "C:\Users\Nigga\Downloads\Miller-Mod-Anylser.ps1"
Usage
When the analyser opens:

Choose your Minecraft mods folder.
Default path: %USERPROFILE%\AppData\Roaming\.minecraft\mods
Press Start Scan.
Results open in a dark GUI showing verified, unknown, suspicious, bypass, obfuscated, and JVM findings.
How It Works
Phase 1: Database Verification
The analyser calculates the SHA1 hash of each JAR file and checks trusted mod databases.

Modrinth API
https://api.modrinth.com/v2/version_file/{hash}

Megabase API
https://megabase.vercel.app/api/query?hash={hash}

Mods found in these databases are marked as Verified.

Phase 2: Full Mod Folder Scan
The analyser scans:

Normal .jar mods
Hidden files
Hidden folders
Nested library folders inside the mods directory
JAR files loaded through launcher/runtime arguments
This helps catch mods or libraries that are not sitting in the normal visible mods list.

Phase 3: Dfabric.addMods Detection
The analyser checks Minecraft/Java launcher arguments for Dfabric.addMods.

This matters because Dfabric.addMods can load extra JAR files outside the normal mods folder flow. If a jar is loaded this way, it is shown in the suspicious results so you can see exactly what was loaded and why it was flagged.

Phase 4: Pattern Analysis
For unverified mods, the analyser:

Opens the JAR file.
Reads internal file names and paths.
Checks .class, .json, and MANIFEST.MF content.
Searches for cheat-related patterns.
Checks for obfuscation and weird package names.
Explains the risk in simple English.
Download Source Tracking
The analyser checks Windows Zone.Identifier data when available to see where a mod was downloaded from.

Usually safer sources:

Modrinth
CurseForge
Riskier sources:

Discord / Discord CDN
MediaFire
GitHub
MEGA
Dropbox
Google Drive
AnyDesk
DoomsdayClient
PrestigeClient
198Macros
Detected Cheat Patterns
The analyser looks for over 100 suspicious patterns.

Combat:
AimAssist, AutoCrystal, AutoHitCrystal, TriggerBot, Velocity, Criticals, Reach, Hitboxes, ShieldBreaker, ShieldDisabler, AxeSpam

Movement:
Flight, AntiKnockback, NoKnockback, JumpReset, SprintReset, NoJumpDelay

PvP Utility:
AutoTotem, AutoArmor, AutoPot, AutoDoubleHand, InventoryTotem, TotemHit, PopSwitch, LagReach, Wtap, FakeLag

Visual:
BlockESP, Freecam, PackSpoof, PingSpoof, FakeNick, FakeItem

Automation:
FastPlace, ChestSteal, Refill, AutoEat, AutoMine, AutoClicker, FastXP

Known Clients:
Asteria, Prestige, Xenon, Argon, Hellion, Grim, Virgin, Donut, Krypton, dev.krypton, dev.gambleclient

Obfuscation / hidden client signs:

Confusing class names
Single-letter package paths
Gibberish class names
Strange mixins
Hidden libraries
Suspicious native/input libraries
jnativehook
imgui
imgui.gl3
imgui.glfw
Result Categories
Verified

Mods found in trusted mod databases.

Unknown

Mods not found in trusted databases, but with no strong suspicious patterns detected.

Suspicious / All Flags

Mods or libraries with suspicious patterns, obfuscation, bypass loading, strange download sources, or anything different from normal verified mods.

Bypass

Mods loaded in unusual ways, including Dfabric.addMods.

Obfuscated

Mods that look intentionally hard to read or verify.

JVM

Runtime or launcher argument findings from the active Java/Minecraft process.

Extra Information
If Minecraft is running, the analyser can show:

Java process name
Process PID
Startup time
Current uptime
Launcher arguments that may load extra JAR files
Contacts
Discord: cwgii

TikTok: cwgicuh

Minecraft Server: aucpvp.net
