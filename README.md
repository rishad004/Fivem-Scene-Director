# 🎬 FiveM Scene Director (Standalone)

A lightweight **cinematic scene director tool** for FiveM, inspired by tools like Spectrum Director and Rockstar Editor.

This project allows you to create, control, and replay in-game scenes with custom actors, camera movement, and timeline-based playback.

---

## 🚀 Features

### 🎭 Actor System

* Spawn actors from saved character templates
* Select and manipulate actors in real-time
* Supports Illenium Appearance integration

### 🎥 Free Camera

* Smooth freecam with mouse control
* Adjustable movement speed
* Cinematic navigation

### 🎬 Camera Keyframes

* Add camera keyframes with duration
* Smooth interpolation (ease in/out)
* Timeline-based playback

### 🎞️ Timeline System (V1)

* Basic timeline playback
* Camera-driven sequencing
* Foundation for full cutscene system

### 🧩 UI Integration

* Simple NUI interface (F5)
* Trigger core actions from UI
* Expandable structure for future panels

### 🗄️ Auto Database Setup

* Tables created automatically on resource start
* No manual SQL setup required

---

## 📦 Requirements

* [oxmysql](https://github.com/overextended/oxmysql)
* [illenium-appearance](https://github.com/iLLeniumStudios/illenium-appearance)

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

4. Start your server

---

## 🗄️ Database

Tables are created automatically on resource start:

* `scene_characters`
* `scene_scenes`

No manual setup required.

---

## 🎮 Usage

### Open UI

```
F5
```

### Free Camera

```
/freecam
```

### Basic Flow

1. Spawn an actor (requires existing character data)
2. Select and position the actor
3. Add camera keyframes
4. Play timeline

---

## ⚠️ Current Limitations (V1)

* No built-in character creator UI yet
* Minimal animation system
* Timeline does not fully control actors yet
* Basic UI (no full editor panels)
* No synced multi-actor animations

---

## 🛣️ Roadmap (V2+)

* Character creation UI (Illenium integration)
* Full animation browser
* Actor panel & selection UI
* Scene save/load system
* Synced animations (multi-actor)
* Timeline editor (drag & resize)
* Camera path visualization
* Gizmo-based controls

---

## 🤝 Contributing

Contributions are welcome. Feel free to:

* Open issues
* Suggest features
* Submit pull requests

---

## 📄 License

MIT License

---

## 💡 Notes

This project is currently in **active development**.
Expect rapid changes and new features.

---

## 🎬 Goal

To provide a **powerful, standalone cinematic tool** for:

* Roleplay servers
* Content creators
* Machinima production
