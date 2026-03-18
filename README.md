# 🎵 SoundPlayer (WoW 3.3.5 Addon)

Simple addon for **playing WoW sounds by ID**, managing your own sound database, and sharing sounds with party members.

![alt text](https://github.com/exewin/soundplayer-wotlk-3.3.5/blob/main/scr.png)

---

## ✨ Features

* ▶️ Play sounds by ID
* 🎲 Random sound generator
* 📡 Listen to party chat (auto-play sound IDs)
* 💾 Personal sound database (SavedVariables)
* 🧾 Add / edit / delete entries
* 🖱️ Minimap icon with drag & position saving
* 🪟 Custom UI with scrollable list
* 📤 Addon message support (send sounds to other players)

---

## 📦 Installation

1. Download or clone this repository
2. Place SoundPlayer folder into:

```
World of Warcraft/Interface/AddOns/
```

3. Restart the game or use:

```
/reload
```

---

## ⚙️ Commands

### General

```
/sp                → Open/close main UI
/sp <id>           → Play sound by ID
/sp rand           → Play random sound
/sp stop           → Restart audio (stop all sounds)
```

### 🎧 Listening

```
/sp listen         → Toggle listening to /party sounds
```

When enabled:

```
/p 12345
```

→ plays sound for everyone with listening ON

---

### 💾 Database

```
/sp db             → Open database window
/sp db <index>     → Play sound from database
/sp add <id> <desc> → Add new sound (description optional)
/sp del <index>    → Delete entry from database
```

---

## 🧠 How Database Works

Each entry:

```
{ id = 12345, desc = "Explosion" }
```

* Index = position in table (`SoundPlayerDB[index]`)
* Stored in SavedVariables:

```
## SavedVariables: SoundPlayerDB
```

---

## 🖱️ UI Features

* Editable descriptions
* Play button per entry
* Delete button
* Scrollable list
* Tooltip help system

---

## 📡 Addon Communication

Supports hidden addon messaging:

```lua
SendAddonMessage("SoundPlayerExe", "12345", "WHISPER", "PlayerName")
```

Receiver will automatically:

* detect message
* play sound

---

## Credits

Created for WoW 3.3.5 (Wrath of the Lich King private servers)

---

## 🧩 License

Free to use, modify, and expand.
