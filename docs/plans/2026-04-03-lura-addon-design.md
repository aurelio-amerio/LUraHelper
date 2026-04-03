# L'Ura Memory Game Addon Design

## Overview
A lightweight, pure Lua World of Warcraft addon designed to help players track a 5-symbol memory sequence mapped against 5 target raid markers. It consists of an interactive input panel and a 5x2 summary panel.

## Components & Architecture
- **Core State (`core.lua`)**: Maintains an array of the currently selected symbol sequence (max length 5).
- **Interactive Panel**: A movable Lua frame containing 6 interactive buttons:
  - 5 symbols: Circle, X, Delta, Tau, Diamond.
  - 1 Reset button (dashed circle).
- **Summary Panel**: A separate movable frame displaying a 5x2 grid:
  - Top Row: 5 standard WoW raid markers.
  - Bottom Row: The sequence of symbols chosen by the player.

## Interaction & Data Flow
1. Player clicks a symbol button on the Interactive Panel.
2. The addon updates the internal array with the selected symbol (if array length < 5).
3. The Summary Panel updates immediately, rendering the symbol into the next available left-to-right slot in the bottom row.
4. Clicking the Reset button clears the array and the bottom row textures, restarting the state.

## Configuration & Settings
- **Interface Options Panel**: Registered natively under `Esc > Options > AddOns`.
- **Slash Command**: Typing `/lura` toggles or opens the native options panel directly.
- **Customization**: The options menu contains 5 dropdowns, each corresponding to one of the 5 top-row slots on the Summary Panel. These dropdowns allow the player to choose from any of the 8 standard WoW raid markers (Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull).
- **Persistence**: Configuration (marker choices) and frame positions are saved via `SavedVariables` (e.g., `LUraMemoryGameDB`) so they persist across reloads and character sessions.
