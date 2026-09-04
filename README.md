# Sunbird

Sunbird is an experimental tick-based RPG engine written in Ruby.

It explores a data-oriented, Quake-inspired simulation model built around authoritative server ticks, indexed runtime state, explicit commands, and a strict separation between authored level data and mutable world state.

**Current version:** `v0.3`

## Current state

Sunbird currently includes:

- integer runtime instance IDs and array-backed component storage;
- reusable entity definitions and authored level spawns;
- immutable `Level` data with terrain, spawn keys, and static relations;
- mutable `World` state with components and runtime relations;
- authoritative `Server#tick` simulation;
- input snapshots and command-based state changes;
- `Planner` + `Resolver` separation;
- breadth-first grid pathfinding;
- shared movement/traversability rules;
- `Move` and `Attack` commands;
- basic health damage resolution;
- an ASCII renderer.

The test level uses `P` for the controlled player and `G` for goblins. Goblins receive authored `:targets` relations, route around blocked terrain, and attack when adjacent.

## Architecture

```text
Entity::Catalog        Level
      |             /    |     \
      |        Terrain  Spawns  Relations
      |             \    |     /
      +-------------- load -----+
                     |
                     v
                   World
                     |
                World::View
                     |
                     v
Input::Snapshot -> Server#tick
                     |
                  Planner
                     |
              Commands::Buffer
                     |
                  Resolver
                     |
                     v
                   World
```

`Level` is immutable authored area data. `World` is mutable runtime state. `Planner` derives intent from read-only state; `Resolver` authoritatively validates and applies it.

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

`v0.3` is primarily a structural release. It normalizes naming and ownership established during the 0.2 prototype rather than adding a large new gameplay system.

Current limitations include uniform-cost pathfinding, no multi-agent path reservation, no death/removal system, no background scheduler, no compiled level format, ASCII-only presentation, no networking, and no multithreaded simulation.
