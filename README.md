[README.md](https://github.com/user-attachments/files/27857930/README.md)# cwgi mod analyser

**Clean PowerShell GUI tool** for scanning Minecraft mods and finding possible cheat clients, hidden libraries, launcher bypasses, and obfuscated jars.

> **Made by cwgi**  
> **Discord:** `cwgii`  
> **TikTok:** `cwgicuh`  
> **Minecraft Server:** `aucpvp.net`

## Installation

### Run straight from GitHub

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/cwgii/Cwgi-Mod-Analyser/main/Miller-Mod-Anylser.ps1')"
```

### Run locally

If you already downloaded the script:

```powershell
powershell -ExecutionPolicy Bypass -File "C:%USERPROFILE%\Downloads\Miller-Mod-Anylser.ps1"
```

## Usage

When **cwgi mod analyser** opens:

- **Choose your Minecraft mods folder**
- **Default path:** `%USERPROFILE%\AppData\Roaming\.minecraft\mods`
- **Press Start Scan**
- **View everything inside the clean dark GUI**

## How it works

### Phase 1: Database verification

The analyser calculates the **SHA1 hash** of each JAR file and checks trusted mod databases.

**Modrinth API**  
`https://api.modrinth.com/v2/version_file/{hash}`

**Megabase API**  
`https://megabase.vercel.app/api/query?hash={hash}`

Mods found in these databases are marked as **VERIFIED**.

### Phase 2: Full mod folder scan

The analyser scans **everything important**, including:

- **Normal `.jar` mods**
- **Hidden files**
- **Hidden folders**
- **Nested library folders**
- **JAR files loaded through launcher/runtime arguments**

This helps catch mods or libraries that are not sitting in the normal visible mods list.

### Phase 3: Dfabric.addMods detection

The analyser checks Minecraft/Java launcher arguments for **`Dfabric.addMods`**.

This matters because **`Dfabric.addMods` can load extra JAR files outside the normal mods folder flow**. If a jar is loaded this way, it is shown in the suspicious results so you can see exactly what was loaded and why it was flagged.

### Phase 4: Pattern analysis

For unverified mods, the analyser checks:

1. **JAR contents**
2. **Internal file names and paths**
3. **`.class`, `.json`, and `MANIFEST.MF` files**
4. **Cheat-related patterns**
5. **Obfuscation and weird package names**
6. **Simple English explanations for why something looks suspicious**

## Download source tracking

The analyser checks Windows `Zone.Identifier` data when available to see where a mod was downloaded from.

### Usually safer sources

- **Modrinth**
- **CurseForge**

### Riskier sources

- **Discord / Discord CDN**
- **MediaFire**
- **GitHub**
- **MEGA**
- **Dropbox**
- **Google Drive**
- **AnyDesk**
- **DoomsdayClient**
- **PrestigeClient**
- **198Macros**

## Detected cheat patterns

The analyser looks for **over 100 suspicious patterns**.

### Combat

`AimAssist`, `AutoCrystal`, `AutoHitCrystal`, `TriggerBot`, `Velocity`, `Criticals`, `Reach`, `Hitboxes`, `ShieldBreaker`, `ShieldDisabler`, `AxeSpam`

### Movement

`Flight`, `AntiKnockback`, `NoKnockback`, `JumpReset`, `SprintReset`, `NoJumpDelay`

### PvP utility

`AutoTotem`, `AutoArmor`, `AutoPot`, `AutoDoubleHand`, `InventoryTotem`, `TotemHit`, `PopSwitch`, `LagReach`, `Wtap`, `FakeLag`

### Visual

`BlockESP`, `Freecam`, `PackSpoof`, `PingSpoof`, `FakeNick`, `FakeItem`

### Automation

`FastPlace`, `ChestSteal`, `Refill`, `AutoEat`, `AutoMine`, `AutoClicker`, `FastXP`

### Known clients

`Asteria`, `Prestige`, `Xenon`, `Argon`, `Hellion`, `Grim`, `Virgin`, `Donut`, `Krypton`, `dev.krypton`, `dev.gambleclient`

### Obfuscation / hidden client signs

- **Confusing class names**
- **Single-letter package paths**
- **Gibberish class names**
- **Strange mixins**
- **Hidden libraries**
- **Suspicious native/input libraries**
- `jnativehook`
- `imgui`
- `imgui.gl3`
- `imgui.glfw`

## Result categories

### Verified

Mods found in trusted mod databases.

### Unknown

Mods not found in trusted databases, but with no strong suspicious patterns detected.

### Suspicious / All Flags

Mods or libraries with suspicious patterns, obfuscation, bypass loading, strange download sources, or anything different from normal verified mods.

### Bypass

Mods loaded in unusual ways, including **`Dfabric.addMods`**.

### Obfuscated

Mods that look intentionally hard to read or verify.

### JVM

Runtime or launcher argument findings from the active Java/Minecraft process.

## Extra information

If Minecraft is running, the analyser can show:

- **Java process name**
- **Process PID**
- **Startup time**
- **Current uptime**
- **Launcher arguments that may load extra JAR files**

## Contacts

**Discord:** `cwgii`  
**TikTok:** `cwgicuh`  
**Minecraft Server:** `aucpvp.net`
