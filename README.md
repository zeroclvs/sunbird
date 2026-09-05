# Sunbird

Sunbird is an experimental game-runtime foundation written in Ruby.

It explores a small data-oriented architecture for grid-based games while keeping simulation, gameplay policy, presentation, and platform I/O separate. The current v0.3 line targets Kitty terminal graphics and an action-driven JRPG-style prototype.

**Current version:** `v0.3c`

## Current state

Sunbird currently includes:

- integer runtime instance IDs and array-backed component storage;
- immutable `Level` data and mutable level-local `World` state;
- persistent `Session` state with a party roster and stable party-member identities;
- authored spawn-key relations resolved to runtime instance relations;
- explicit commands with authoritative resolution;
- table-driven NPC behavior, BFS pathfinding, collision, movement, and attacks;
- `ModeStack` with exploration and dialogue modes;
- facing state and adjacent-tile interaction;
- authored dialogue content referenced through `Interactable` components;
- `Simulation#plan` separated from `Simulation#step`;
- backend-neutral `Render::Scene` projection;
- semantic render keys and PNG assets;
- a Kitty graphics renderer with persistent image placements;
- persistent raw terminal input with WASD, arrows, Enter/Space, Escape, Q, and Ctrl-C handling.

The current test level retains the earlier goblin simulation behavior and adds one villager that can be approached and spoken to. Goblins route around blocked terrain and attack when adjacent.

## Rendering

The active v0.3c render path is:

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

`Render::Scene` remains backend-neutral because the presentation boundary is intended to survive later renderer experiments.

`Render::Kitty` maps semantic render keys such as `:player`, `:goblin`, `:villager`, and `:water` to PNG files under `content/sprites/`, uploads each image once, and keeps stable placements between frames.

The older `Render::Ascii` implementation and fallback-glyph metadata are still present in the source tree as legacy/reference code, but v0.3c does not select the ASCII renderer at runtime. The dual ASCII/Kitty state is preserved historically in v0.3a.

Dialogue currently reuses the terminal status row rather than introducing a separate UI-overlay system. This keeps v0.3c focused on interaction and mode transitions.

## Architecture

```text
                    App
                     |
                  Session
                     |
                 ModeStack
                /         \
       Exploration       Dialogue
            |                |
            |           pauses simulation
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

Exploration handles facing and interaction policy. An adjacent `Interactable` can request a `DialogueMode`; `App` applies the resulting mode-stack push/pop transition. Dialogue input does not advance the exploration simulation.

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
W / ↑          move north
S / ↓          move south
A / ←          move west
D / →          move east
Enter / Space  interact / advance dialogue
Esc            close dialogue; quit from exploration
Q              quit
```

To speak to the villager, stand beside them, face toward them, and press Enter or Space.

If Kitty graphics support is not detected, v0.3c exits instead of silently falling back to ASCII.

## Tests

```sh
bundle exec ruby -Itest -e \
  'Dir["test/*_test.rb"].sort.each { |file| require_relative file }'
```

## Project status

`v0.3c` adds the first non-exploration gameplay context on top of the v0.3b Session/Party foundation. `Facing` and `Interactable` provide a minimal JRPG interaction model, while `DialogueMode` proves that `ModeStack` can suspend exploration, consume its own input, and return control without advancing the underlying simulation.

The dialogue system is intentionally small: authored dialogue is currently a sequence of lines referenced by a dialogue key, with no branching, conditions, portraits, scripting, or persistent conversation flags.

Enhanced Kitty press/release event handling, animation/interpolation, persistent actor stats (HP/MP/equipment), battle/menu systems, save data, richer dialogue logic, and fixed-step action scheduling remain later work. Sunbird remains the Ruby research/prototype implementation; renderer experiments such as Raylib can be explored independently in later branches.
