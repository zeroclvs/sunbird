# Sunbird

Sunbird is an experimental tick-based RPG engine written in Ruby.

The project explores a data-oriented simulation architecture inspired by Quake-style authoritative world state, while keeping the design portable to systems languages such as Rust or Odin.

**Current version:** `v0.2c`

## Current state

Sunbird currently has:

* integer runtime instance IDs;
* array-backed component storage;
* reusable entity definitions and level spawns;
* immutable level terrain and mutable runtime world state;
* an authoritative `Server#tick`;
* input snapshots and command-based simulation;
* runtime entity relations;
* terrain and entity collision;
* wandering and relation-driven chase behavior;
* a simple ASCII renderer.

The current test level contains a player (`P`), goblins (`G`), grass, water, and impassable boundaries.

Goblin chase behavior is intentionally primitive. It prefers horizontal movement and does not yet perform pathfinding, so NPCs can become stuck behind terrain or other entities.

## Architecture

The core simulation path is:

```text
Input::Snapshot
      ↓
Server#tick
      ↓
TickBuilder
      ↓
CommandBuffer
      ↓
Resolver
      ↓
World
```

`Server#tick` is the authoritative operation that advances simulation state.

`TickBuilder` reads world state, relations, active instances, and input to produce intent. `Resolver` applies commands and performs authoritative world mutations.

Rendering remains outside the simulation domain.

See [`docs/architecture.md`](docs/architecture.md) for the more detailed design notes.

## Requirements

Ruby 3.2 or newer.

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
Q        quit
```

## Tests

Run the complete test suite:

```sh
bundle exec ruby -Itest -e \
  'Dir["test/*_test.rb"].sort.each { |file| require_relative file }'
```

## Project status

Sunbird is an architecture and gameplay prototype, not a production-ready engine.

Several systems are deliberately deferred until the core simulation model is better understood, including pathfinding, combat, background scheduling, binary level data, graphical rendering, networking, and multithreading.

