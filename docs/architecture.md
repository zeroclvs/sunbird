# Sunbird v0.2d Architecture

Sunbird is an experimental tick-based RPG engine. The Ruby implementation is used to explore simulation semantics while keeping the logical architecture portable to systems languages later.

## Core rules

- Runtime instances use integer IDs.
- Hot runtime data lives in component tables rather than game-object inheritance trees.
- Reusable `Entity` definitions are separate from level `Spawn`s and runtime instances.
- `Level` represents immutable environment data.
- `World` owns mutable runtime components and relations.
- `Server#tick` is the authoritative operation that advances simulation state.
- Player and NPC decisions produce commands rather than mutating `World`.
- Rendering reads world state but never changes it.

## Server tick

A tick is an operation, not a stored `Tick` object.

```text
Input::Snapshot
      |
      v
Server#tick
      |
      +--> TickBuilder
      |       |
      |       +--> Activation
      |       +--> Level
      |       +--> World::View
      |       +--> runtime relations
      |       +--> behaviors
      |       +--> Pathfinder
      |       |
      |       v
      |   CommandBuffer
      |
      +--> Resolver
      |       |
      |       v
      |     World
      |
      +--> increment tick number
```

`Server#tick` should remain small. Planning complexity belongs in `TickBuilder`; authoritative mutation belongs behind `Resolver`.

## Entities, spawns, and instances

`Entity` is a reusable content definition such as `:player` or `:goblin`.

A level stores placements:

```text
Spawn(entity: :goblin, x: 14, y: 10)
```

Loading a spawn creates a runtime instance identified by an integer `InstanceId`.

Conceptually:

```text
Entity definition
       +
Spawn
       |
       v
runtime InstanceId
       |
       +--> Position
       +--> Health
       +--> Renderable
       +--> Behavior
       +--> Collision
```

Instances created from the same definition have independent runtime state.

## World and World::View

`World` owns mutable component tables and runtime relations.

Conceptually:

```text
positions[instance_id]
health[instance_id]
renderables[instance_id]
behaviors[instance_id]
collisions[instance_id]
```

`World::View` is the read-only query boundary used by planning code. It exposes instance IDs, components, and relation queries but not mutation methods such as `set_component`.

## Runtime relations

Relations are stored with `World`.

The current relation record is:

```text
kind
source_id
target_id
```

The first gameplay relation is:

```text
targets(goblin, player)
```

The server establishes these relations when the level is loaded. `TickBuilder` reads them to decide what a chasing goblin should do.

Relation storage is intentionally simple and currently uses a linear edge list.

## Activation

`Server::Activation` selects the runtime instances that participate in planning.

The v0.2 implementation activates every instance. The boundary exists so a later policy can select a smaller working set without changing `Server#tick`.

## TickBuilder and behavior

`TickBuilder` inspects the stable input snapshot plus current read-only simulation state and produces commands.

Player movement:

```text
Input::Snapshot
      ↓
player_move
      ↓
Move
```

NPC behavior is selected from the instance's `Behavior` component.

Current kinds are:

```text
:idle
:wander
:chase
```

Player and NPC logic share the same command pipeline.

## Pathfinding

`v0.2d` introduces `Server::Pathfinder`.

The current map has uniform movement cost, so pathfinding uses breadth-first search (BFS). On this grid BFS produces a shortest path without the extra machinery required by weighted search.

For chase behavior, the pathfinder:

1. reads the source and target positions;
2. finds passable cells adjacent to the target;
3. treats currently blocking runtime instances as occupied;
4. searches for the shortest reachable route to one of those adjacent cells;
5. returns only the next cardinal step.

The pathfinder plans from `World::View`; it does not mutate anything.

```text
Level passability
       +
World blockers
       +
target relation
       |
       v
Pathfinder
       |
       v
next (dx, dy)
       |
       v
Move command
```

### Planning is not authority

Pathfinding does not replace collision checks in `Resolver`.

All NPC commands for a tick are planned against the same pre-resolution world state. Another instance may therefore move before a planned command is resolved.

`Resolver` always re-checks the chosen movement step against the authoritative current state.

This preserves the boundary:

```text
Pathfinder / TickBuilder
        = planned intent

Resolver
        = authoritative legality and mutation
```

There is currently no multi-agent path reservation or coordinated movement. Two goblins may plan the same destination; sequential resolution determines which one succeeds.

## Commands

Sunbird v0.2d has two command types.

### Move

```text
Move(instance, dx, dy)
```

Movement resolution checks:

1. terrain passability;
2. dynamic occupancy;
3. then replaces `Position`.

### Attack

```text
Attack(attacker, target, damage)
```

A chasing goblin emits `Attack` when already adjacent to its target.

The resolver applies damage by replacing the target's `Health` value. Health is clamped at zero.

There is intentionally no death/removal system yet.

## Level and World

Static environment data and mutable simulation state remain separate.

```text
Level
  terrain
  map dimensions
  terrain passability
  spawn descriptions

World
  runtime components
  positions
  health
  behaviors
  runtime relations
```

The current Ruby content files are temporary source representations behind loaders. They are not the intended final persistent format.

## Input

Physical input stays outside the server.

```text
terminal input
      ↓
Input::Mapper
      ↓
Action
      ↓
Input::Handoff
      ↓
Input::Snapshot
      ↓
Server#tick
```

The server sees abstract actions rather than terminal bytes or escape sequences.

## Rendering

Rendering remains outside authoritative simulation:

```text
Server.world_view + Server.level
        ↓
Render::Projector
        ↓
Render::Frame
        ↓
Render::Ascii
        ↓
Host::Terminal
```

Rendering never mutates `World`.

## Known v0.2d limits

The final 0.2 architecture deliberately leaves several problems unresolved:

- pathfinding assumes uniform tile cost;
- paths are recalculated independently by each chasing instance;
- there is no path cache or navigation graph;
- there is no multi-agent reservation or crowd coordination;
- sequential command resolution can still create temporary movement conflicts;
- dead instances are not removed;
- combat has no stats, equipment, armor, or damage types;
- Activation still selects every instance;
- simulation ticks are not wall-clock paced;
- there is no background scheduler;
- level data is not compiled to a binary format;
- rendering is still ASCII;
- there is no networking or multithreaded simulation.

These limits are useful boundaries for later design work rather than problems to hide inside v0.2.

## Next branch

`v0.3` is intended to focus first on naming and repository-structure cleanup before adding more systems. That cleanup can also remove stale version-specific comments and tighten terminology around runtime IDs, entity definitions, level data, and server planning.
