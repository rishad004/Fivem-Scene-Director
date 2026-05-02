# 🎬 FiveM Scene Director (Standalone)

A lightweight **cinematic scene director tool** for FiveM, inspired by tools like Spectrum Director and Rockstar Editor.

Create, control, and replay in-game scenes with custom actors, camera movement, timeline-based playback, and full scene persistence — all from the UI. No commands needed once the panel is open.

---

## 🚀 Features

### 🎭 Actor System
- Spawn actors from saved character templates (enter ID → Spawn)
- Select nearest actor via **UI button** (no command needed)
- Move/rotate/position actors with WASD + Q/E while selected
- Real-time selected actor feedback in the UI
- Supports Illenium Appearance integration

### 🎥 Free Camera
- Toggle freecam from the **UI button** or press **F6**
- Hold **RMB** to mouse-look, **WASD** to fly, **Q/E** for vertical, **Scroll** to change speed
- UI button updates live to show freecam ON/OFF state
- NUI focus is automatically managed (restored when freecam is turned off)

### 🎬 Camera Keyframes
- Add camera keyframes with a configurable duration (inline input, no popups)
- Smooth interpolation (ease in/out)
- Timeline-based playback

### 🎞️ Timeline System
- Add steps with inline duration input — no browser prompts
- Edit step duration inline with confirm/cancel buttons
- Remove steps with a built-in double-tap confirmation (no popups)
- Camera + actor positions snapshotted per step
- Smooth actor movement and camera interpolation during playback

### 🧩 UI (No-Command Design)
- Open/close with **F5** (or `/director`)
- **Escape** closes the UI from anywhere
- All actions — freecam, actor select, spawn, animations, timeline, save/load — are accessible from the panel
- Inline JSON import via a text area (no prompts)
- Scene name input inline (no prompts)
- Toast notifications instead of browser alerts

### 🗄️ Scene Persistence
- Save named scenes to the server database
- Load scenes by clicking from the scene list
- Delete scenes with inline double-tap confirmation
- Search/filter saved scenes
- Auto table creation on resource start — no manual SQL setup

---

## 📦 Requirements

- [oxmysql](https://github.com/overextended/oxmysql)
- [illenium-appearance](https://github.com/iLLeniumStudios/illenium-appearance)

---

## ⚙️ Installation

1. Clone or download this repository into your `resources` folder:

   ```bash
   git clone https://github.com/your-username/fivem-scene-director.git
   ```

2. Add to your `server.cfg`:

   ```
   ensure scene-director
   ```

3. Make sure dependencies are started **before** this resource:

   ```
   ensure oxmysql
   ensure illenium-appearance
   ```

4. Start your server — database tables are created automatically.

---

## 🗄️ Database

Tables are created automatically on resource start:

- `scene_characters` — stores character appearance data
- `scene_scenes` — stores named scene timelines

No manual SQL setup required.

---

## 🎮 Controls

### Opening the UI

| Key | Action |
|-----|--------|
| `F5` | Open / close Scene Director UI |
| `Escape` | Close UI |

### Freecam (activate from UI button or F6)

| Input | Action |
|-------|--------|
| Hold `RMB` | Mouse look |
| `W / S` | Fly forward / backward |
| `A / D` | Strafe left / right |
| `Q / E` | Move up / down |
| Scroll wheel | Increase / decrease speed |

### Actor Controls (actor selected, freecam OFF)

| Key | Action |
|-----|--------|
| `W / S` | Move actor forward / backward |
| `A / D` | Rotate actor left / right |
| `Q / E` | Move actor up / down |

---

## 🔁 Basic Workflow

1. Press **F5** to open the UI
2. Enter a Character ID and click **Spawn**
3. Walk near the actor and click **🎯 Select Nearest Actor**
4. Use WASD/Q/E to position them
5. Click **📷 Toggle Freecam**, fly to your shot position
6. Click **📷 Toggle Freecam** again to exit and return to the UI
7. Set a duration and click **➕ Add** to add a timeline step
8. Repeat for each keyframe
9. Click **▶ Play Timeline** to preview
10. Enter a scene name and click **💾 Save** to persist

---

## ⚠️ Known Limitations

- No drag-and-drop timeline reordering
- No multi-actor synced animations
- Actor respawning after import requires actors to already be in the world
- No camera path visualization

---

## 🛣️ Roadmap

- Drag-and-drop timeline reordering
- Multi-actor synced animations
- Camera path gizmo visualization
- Scene export to file download
- Per-actor animation locking per step
- Undo/redo support

---

## 🤝 Contributing

Contributions are welcome. Feel free to:

- Open issues
- Suggest features
- Submit pull requests

---

## 📄 License

MIT License

---

## 🎬 Goal

To provide a **powerful, standalone cinematic tool** for:

- Roleplay servers
- Content creators
- Machinima production
