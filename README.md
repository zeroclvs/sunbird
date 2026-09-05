# Sunbird

Sunbird is an experimental game-runtime foundation written in Ruby.

It explores a small data-oriented architecture for grid-based games while keeping simulation, gameplay policy, presentation, and platform I/O separate. The current demo is an action-driven exploration game that can render as plain ASCII or as PNG tiles/sprites through the Kitty graphics protocol.

**Current version:** `v0.3a`

## Current state

Sunbird currently includes:

- integer runtime instance IDs and array-backed component storage;
- immutable `Level` data and mutable level-local `World` state;
- authored spawn-key relations resolved to runtime instance relations;
- explicit commands with authoritative resolution;
- table-driven NPC behavior, BFS pathfinding, collision, movement, and attacks;
- `ModeStack` with an action-driven exploration mode;
- `Simulation#plan` separated from `Simulation#step`;
- backend-neutral `Render::Scene` projection;
- semantic render keys with ASCII fallback glyphs;
- an ASCII renderer;
- a Kitty graphics renderer using PNG assets;
- automatic Kitty/ASCII renderer selection at the terminal boundary.

The current test level uses the same simulation in both renderers. Goblins route around blocked terrain and attack when adjacent.

## Rendering

The render path is:

```text
Level + World::View
        |
        v
Render::Projector
        |
        v
Render::Scene
       / \
      /   \
 ASCII   Kitty
          |
       PNG assets
```

`Render::Scene` is backend-neutral. `Render::Ascii` uses fallback glyphs and keeps the simple full-screen redraw model. `Render::Kitty` maps semantic render keys such as `:player`, `:goblin`, and `:water` to PNG files under `content/sprites/`, uploads each image once, and keeps stable terminal placements between frames.

Kitty is selected automatically when Sunbird detects a Kitty terminal environment. To force a renderer:

```sh
SUNBIRD_RENDERER=ascii bundle exec ruby bin/sunbird
SUNBIRD_RENDERER=kitty bundle exec ruby bin/sunbird
```

The explicit `kitty` override is useful when testing another terminal that implements the Kitty graphics protocol but is not yet recognized by v0.3a's conservative auto-detection.

## Architecture

```text
                    App
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
                         /        \
                  Render::Ascii  Render::Kitty
                         \        /
                          \      /
                        Host::Terminal
```

A simulation **step is a state transition, not a clock tick**. The active mode decides when a step occurs. Rendering remains independent of simulation authority.

See [`docs/architecture.md`](docs/architecture.md) for details.

## Requirements

Ruby 3.2 or newer.

```sh
bundle install
```

For graphical rendering, use Kitty or force the Kitty backend in another terminal that supports the Kitty graphics protocol.

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
Q        quit
```

## Tests

```sh
bundle exec ruby -Itest -e \
  'Dir["test/*_test.rb"].sort.each { |file| require_relative file }'
```

## Project status

`v0.3a` is the first graphical-terminal milestone. It keeps the v0.3 runtime foundation intact while adding a small renderer-facing asset layer and a Kitty protocol backend with persistent placements, synchronized redraws, and alternate-screen lifecycle. Kitty keyboard input, animation/interpolation, JRPG battle/menu systems, persistent party state, and fixed-step action scheduling remain later work.
