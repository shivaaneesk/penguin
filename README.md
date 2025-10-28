# 🐧 Penguin

A tile-based game where a player and an AI penguin compete to collect fish on a shrinking ice field.

## 🕹️ Gameplay

The goal is to collect more fish than the AI before you both get stuck.

* **Objective:** Control the player penguin to collect fish from ice tiles. Each fish adds to your score.
* **Ice Durability:** Each ice tile starts with 3 durability points.
* **Breaking Ice:** Every time a penguin moves onto a tile, that tile's durability decreases by 1.
* **Holes:** When a tile's durability reaches 0, it is erased from the map, leaving a hole.
* **Movement:** Penguins slide in a straight line until they hit a wall or an empty space. You cannot move onto a tile that has already been erased.
* **The AI:** An AI-controlled penguin moves simultaneously, also collecting fish and breaking ice. The AI will prioritize moving to adjacent tiles with fish and try to maintain its momentum if the path is clear.

## ⌨️ Controls

The game uses the following input actions:

* `move_up`
* `move_down`
* `move_left`
* `move_right`

**Note:** The `project.godot` file defines these actions but does **not** assign any keys to them. You must map these actions to your keyboard (e.g., Arrow Keys or W/A/S/D) in **Project > Project Settings > Input Map** to control the penguin.

## ⚙️ How to Run

1.  Open this project folder in the **Godot Engine (v4.5** or newer).
2.  Go to **Project > Project Settings > Input Map**.
3.  Add key assignments (e.g., the Up Arrow key) for the `move_up`, `move_down`, `move_left`, and `move_right` actions.
4.  Run the main scene, which is `game_board.tscn`.
5.  (Before it will work, you must debug the boundary issue mentioned in the warning.)

## 📁 Project Files

* **`project.godot`**
    * Defines the project configuration, including the project name "Penguin", input maps, and the main scene.
* **`game_board.tscn`**
    * The main scene for the game.
    * Contains the `TileMap`, `PlayerPenguin`, `AiPenguin`, and the `ScoreLabel`.
* **`game_board.gd`**
    * The primary script for the game.
    * Manages game setup, player input, AI logic, score, and the tile durability/breaking mechanic.
* **`penguin.tscn`**
    * A scene for the penguin character.
    * Used as an instance for both the player and the AI.
* **`penguin.gd`**
    * The script for the penguin character.
    * Handles the logic for updating its visual position on the screen based on its grid position.
