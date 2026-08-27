# Sunbird

Sunbird is an experimental tick-based RPG engine written in Ruby.

It explores a data-oriented, Quake-inspired simulation model built around authoritative server ticks, indexed runtime state, explicit commands, and a clean separation between immutable level data and mutable world state.

**Current version:** `v0.2d`

## Current state

Sunbird currently includes:

- integer runtime instance IDs and array-backed component storage;
- reusable entity definitions and level spawns;
- authoritative `Server#tick` simulation;
- input snapshots and command-based state changes;
- runtime entity relations;
- terrain and entity collision;
- wandering and relation-driven chase behavior;
- breadth-first grid pathfinding around terrain and blocking entities;
- `Move` and `Attack` commands;
- basic health damage resolution;
- a simple ASCII renderer.

The current test level uses `P` for the player and `G` for goblins. Goblins target the player, find a shortest route around obstacles, stop adjacent to the target, and attack.

## Architecture

```text
Input::Snapshot
      ↓
Server#tick
      ↓
TickBuilder
  ├── Activation
  ├── relations
  ├── behavior
  └── Pathfinder
      ↓
CommandBuffer
      ↓
Resolver
      ↓
World
```

`TickBuilder` plans intent from read-only state. `Resolver` remains authoritative: it re-checks movement legality and applies world mutations.

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

`v0.2d` is the final milestone in the 0.2 branch. Sunbird remains an architecture and gameplay prototype.

Pathfinding currently assumes uniform movement cost and there is no multi-agent path reservation, death/removal system, background scheduler, binary level format, graphical renderer, networking, or multithreaded simulation.

The next branch (`v0.3`) is intended to clean up project structure and terminology before the simulation grows further.
