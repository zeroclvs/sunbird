# Sunbird

Sunbird is an experimental game-runtime foundation written in Ruby.

It explores a small data-oriented architecture for grid-based games while keeping simulation, gameplay policy, presentation, and platform I/O separate. The current demo is an ASCII exploration game, but v0.3 is intended to support both action/turn-driven JRPG experiments and fixed-step action games such as metroidvanias.

**Current version:** `v0.3`

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
- an ASCII renderer and terminal host boundary.

The current test level uses `P` for the controlled player and `G` for goblins. Goblins route around blocked terrain and attack when adjacent.

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
                              |
                        Render::Ascii
                              |
                       Host::Terminal
```

A simulation **step is a state transition, not a clock tick**. The active mode decides when a step occurs. The current exploration mode advances after actionable input; a future metroidvania mode can drive the same simulation from a fixed-step clock.

See [`docs/architecture.md`](docs/architecture.md) for details.

## Requirements

Ruby 3.2 or newer.

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
Q        quit
```

## Tests

```sh
bundle exec ruby -Itest -e \
  'Dir["test/*_test.rb"].sort.each { |file| require_relative file }'
```

## Project status

`v0.3` is a common foundation rather than a commitment to one game loop. ASCII remains the reference renderer. Kitty/Ghostty graphics, richer terminal input, presentation interpolation, JRPG battle/menu systems, and fixed-step action scheduling are intentionally deferred to later increments.
