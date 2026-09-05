# Sunbird

Sunbird is an experimental game-runtime foundation written in Ruby.

It explores a small data-oriented architecture for grid-based games while keeping simulation, gameplay policy, presentation, and platform I/O separate. The current v0.3 line targets Kitty terminal graphics and an action-driven JRPG-style exploration prototype.

**Current version:** `v0.3b`

## Current state

Sunbird currently includes:

- integer runtime instance IDs and array-backed component storage;
- immutable `Level` data and mutable level-local `World` state;
- persistent `Session` state with a party roster and stable party-member identities;
- authored spawn-key relations resolved to runtime instance relations;
- explicit commands with authoritative resolution;
- table-driven NPC behavior, BFS pathfinding, collision, movement, and attacks;
- `ModeStack` with an action-driven exploration mode;
- `Simulation#plan` separated from `Simulation#step`;
- backend-neutral `Render::Scene` projection;
- semantic render keys and PNG assets;
- a Kitty graphics renderer with persistent image placements;
- persistent raw terminal input with WASD, arrows, Escape, Q, and Ctrl-C handling.

The current test level has the same simulation behavior established earlier: goblins route around blocked terrain and attack when adjacent.

## Rendering

The active v0.3b render path is:

```text
Level + World::View
        |
        v
Render::Projector
        |
        v
Render::Scene
        |
        v
Render::Kitty
        |
        v
PNG assets
        |
        v
Host::Terminal
```

`Render::Scene` remains backend-neutral because the presentation boundary is intended to survive the later Raylib transition.

`Render::Kitty` maps semantic render keys such as `:player`, `:goblin`, and `:water` to PNG files under `content/sprites/`, uploads each image once, and keeps stable placements between frames.

The older `Render::Ascii` implementation and fallback-glyph metadata are still present in the source tree as legacy/reference code, but v0.3b no longer selects the ASCII renderer at runtime. The dual ASCII/Kitty state is preserved historically in v0.3a.

## Architecture

```text
                    App
                     |
                  Session
                     |
                 ModeStack
                     |
                Active Mode
                     |
          decides when to advance
                     |
                     v
                Simulation
               /          \
          Planner        Resolver
             |               |
             v               v
      Commands::Buffer ---> World
                              |
                         World::View
                              |
                              v
                     Render::Projector
                              |
                              v
                       Render::Scene
                              |
                              v
                       Render::Kitty
                              |
                              v
                       Host::Terminal
```

A simulation **step is a state transition, not a clock tick**. The active mode decides when a step occurs. `Session` owns persistent party identity above the level-local Simulation/World, and Exploration binds the current party leader to the Level entry spawn.

See [`docs/architecture.md`](docs/architecture.md) for details.

## Requirements

- Ruby 3.2 or newer
- Kitty, or another terminal environment currently detected as supporting the Kitty graphics protocol

Install dependencies:

```sh
bundle install
```

## Run

```sh
bundle exec ruby bin/sunbird
```

Controls:

```text
W / ↑    move north
S / ↓    move south
A / ←    move west
D / →    move east
Q / Esc  quit
```

If Kitty graphics support is not detected, v0.3b exits instead of silently falling back to ASCII.

## Tests

```sh
bundle exec ruby -Itest -e \
  'Dir["test/*_test.rb"].sort.each { |file| require_relative file }'
```

## Project status

`v0.3b` keeps terminal input deliberately small before the planned Raylib transition and introduces the first persistent JRPG-facing state above the level-local simulation: `Session` owns a `Party`, while `Mode::Exploration` binds the party leader to the current Level entry spawn.

Enhanced Kitty press/release event handling, animation/interpolation, persistent actor stats (HP/MP/equipment), JRPG battle/menu/dialogue systems, save data, and fixed-step action scheduling remain later work. Raylib is planned as the primary graphics/input transition for v0.4.
