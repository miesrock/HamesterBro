# HamsterBroProject

**Godot 4.3** / Forward Plus / Entry: `res://scenes/Main.tscn`

## Script class_name pattern

Every script uses `class_name` (Enemy, CombatDirector, RainbowBullet, etc.) and is instantiated via `preload("res://scripts/<name>.gd")`, NOT via `.tscn` PackedScene. Scenes exist only for Player and test_environment.

## Two player.gd files — don't edit the wrong one

- `scenes/player.gd` — **the real player script** (used by Player.tscn)
- `scripts/player.gd` — empty stub, ignore

## Input & movement

- WASD movement, Space = jump AND dash (same key mapped twice)
- Visual pivot has 180° yaw offset — hamster model faces backwards by default

## Combat is fully automated

`CombatDirector` auto-targets nearest "enemies" group member and fires bursts of 3 bullets. Enemies die in one hit (`queue_free()`). Spawner keeps ~120 alive in a ring 18–28 units from player.

## All audio is procedural

`juicy_audio.gd` generates every sound via `AudioStreamWAV` synthesis. No audio asset files needed.

## NodePath wiring

Main.tscn wires components via exported `NodePath` properties (player_path, audio_path, muzzle_path, etc.). When adding new nodes, replicate this pattern.

## .tscn format quirks

- SubResources must be defined **before** the nodes that reference them
- `load_steps` count must match total sub+ext resources
- Resource IDs cannot contain spaces

## Dev commands

```bash
# Launch Godot editor
godot --editor

# Run the game
godot res://scenes/Main.tscn

# Run with debug
godot --debug-collisions res://scenes/Main.tscn
```
