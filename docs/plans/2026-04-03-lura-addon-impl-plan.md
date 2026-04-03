# L'Ura Memory Game Implementation Plan

> **For Antigravity:** REQUIRED SUB-SKILL: Load executing-plans to implement this plan task-by-task.

**Goal:** Build a WoW Addon with an interactive input panel and a static summary panel to track a 5-symbol memory game mapped to custom world markers.

**Architecture:** Pure Lua implementation using `CreateFrame` for UI construction and standard WoW events for state management. Uses `SavedVariables` for configuration persistence. No external libraries like Ace3.

**Tech Stack:** World of Warcraft Lua API.

---

### Task 1: Addon Manifest and Core Initialization

**Files:**
- Create: `LUraMemoryGame.toc`
- Create: `core.lua`

**Step 1: Write the `.toc` manifest**
Create `LUraMemoryGame.toc` defining `LUraMemoryGameDB` as SavedVariables and loading `core.lua`.

**Step 2: Initialize Core Addon and SavedVariables**
In `core.lua`, setup the namespace, an event frame listening to `ADDON_LOADED`, and initialize `LUraMemoryGameDB` with a default array of 5 standard markers (Star, Circle, Diamond, Triangle, Moon) if it does not exist.

**Step 3: Commit**
```bash
git add LUraMemoryGame.toc core.lua
git commit -m "feat: init addon and saved variables"
```

### Task 2: Create the Options Menu

**Files:**
- Modify: `core.lua`

**Step 1: Build the Options Panel UI**
In `core.lua`, construct the frame for the Interface Options. Add 5 dropdown components mapping to the 5 world marker positions. Add a slash command `/lura` to open it.

**Step 2: Commit**
```bash
git add core.lua
git commit -m "feat: add options panel and slash command"
```

### Task 3: Interactive Panel Creation

**Files:**
- Modify: `core.lua`

**Step 1: Build Interactive Panel**
In `core.lua`, create the movable interactive frame containing the 5 symbol buttons (Circle, X, Delta, Tau, Diamond) and 1 reset button. Ensure it displays when outside of combat and hides in combat if necessary (or just stays as a freely togglable panel).

**Step 2: Commit**
```bash
git add core.lua
git commit -m "feat: add interactive panel with 6 buttons"
```

### Task 4: Summary Panel & Data Binding

**Files:**
- Modify: `core.lua`

**Step 1: Build Summary Panel**
In `core.lua`, create the movable summary frame. Top row displays 5 textures based on `LUraMemoryGameDB`. Bottom row creates 5 empty texture slots.

**Step 2: Implement Interaction Logic**
In `core.lua`, connect the buttons from Task 3 to an internal sequence array. Update the bottom row of the Summary Panel when buttons are clicked. Wire the Reset button to clear the sequence. Refresh top row if options are changed.

**Step 3: Commit**
```bash
git add core.lua
git commit -m "feat: implement summary panel and gameplay logic"
```
