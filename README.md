# L'Ura Helper

A World of Warcraft addon for tracking symbol sequences against raid markers during the L'Ura encounter in Midnight Falls.

<img src="https://raw.githubusercontent.com/aurelio-amerio/LUraHelper/refs/heads/main/imgs/interface.jpg" alt="Interface" width=600>

## Setup

1. Create a custom chat channel, for example by typing: `/channel myraidchannel123`
2. Ensure the entire raid joins this custom channel.
3. Take note of the chat channel number (this might be different for each person).
4. Open the settings with `/lura` and type the chat channel number. This is the channel the addon will monitor for sequences.
5. **Raid Assistants/Leaders:** Make sure to uncheck the "Hide Interactive Panel" in the options, as it is hidden by default. Only assistants need the interactive panel to broadcast the order.
6. *(Optional)* Move the panels to your preferred position, lock them so you don't accidentally move them, and save your profile with a new name.
7. *(Optional)* Change the order of the raid markers or disable unneeded ones. For example, on Normal difficulty, you only need 3 raid markers.

## Usage

* **Raiders:** No action during combat is required! Just make sure you joined the correct chat channel and entered its number in the configuration panel (`/lura`).
* **Raid Assistant:** 
  1. Click the symbols on the interactive panel as they appear over L'Ura's head.
  2. Once the sequence is filled, click the **Send to chat** button. This creates a pre-computed chat message in a copy-paste window.
  3. Press `Ctrl+C` to copy the sequence.
  4. Press `Escape` to close the copy-paste window.
  5. Press `Enter` to open your regular chat input, and paste the copied message (`Ctrl+V`) into your regular chat window. The message goes to the configured custom channel.
  6. The synced sequence will instantly appear on the top Summary Panel for everyone in the raid.
  7. **Resetting between rounds:** You can press the red **Cancel (Ø)** button to get a `"...."` string in a copy-paste window. Copy and paste this into chat just like a regular sequence. It resets the view for everyone to the first left panel, making it clear that a new round hasn't started yet and old assignments are cleared.

## Installation

1. Install the addon from Wago, or copy the `LUraHelper` folder into your WoW `Interface/AddOns/` directory.
2. Restart WoW (to load the addon fonts) or type `/reload` in chat (if you have already installed the addon previously).

## Slash Commands

All commands use the `/lura` prefix:

| Command | Description |
|---|---|
| `/lura` | Open the options panel |
| `/lura help` | Print a summary of all slash commands |
| `/lura toggle` | Toggle panel visibility (hide/show) |
| `/lura lock` | Lock panel positions |
| `/lura unlock` | Unlock panel positions |

## Features

### Interactive Panel
A compact button bar with 5 symbol buttons (O, X, Δ, T, ◆) and a cancel/reset button. Click symbols to build a sequence that maps to the configured raid markers. The panel is draggable and can be locked in place.

### Summary Panel
Displays the configured raid markers on the top row and the player's selected symbol sequence on the bottom row. Includes its own reset button. Also draggable and lockable.

### Panel Scaling
Both the Summary and Interactive panels can be scaled independently from 0.01× to 5× via sliders or direct numeric input in the options panel.

### Named Profiles
Create, switch, and delete named configuration profiles. Each profile stores its own marker sequence, lock/hide state, frame positions, and scale. A **Default** profile is always present and cannot be deleted.

### Configurable Marker Sequence
Remap each of the 5 symbol slots to any WoW raid marker (Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull) or set a slot to **None** to disable it.

### Import / Export
Export the current profile as a Base64-encoded string and share it with others. Importing prompts for a profile name and asks for overwrite confirmation if the name already exists.

### Options Panel
Accessible via `/lura` or the WoW Interface → AddOns menu. Provides checkboxes for Lock, Hide, and Test Mode, plus buttons for profile management, restore defaults, and import/export.

## File Structure

| File | Purpose |
|---|---|
| `core.lua` | Event handling, database initialization, visibility/lock/scale logic |
| `profiles.lua` | Profile CRUD, position save/restore, UI refresh |
| `panels.lua` | Interactive and summary panel creation, sequence logic |
| `options.lua` | Options panel, slash command handler, scale sliders |
| `importexport.lua` | Base64 encoding, XML config export/import, import UI |

---

*Made by Deino for Poetic Justice - Ravencrest*
