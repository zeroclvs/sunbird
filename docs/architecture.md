# Sunbird v0.3 Architecture

Sunbird is an experimental tick-based RPG engine. The Ruby implementation is a rapid architecture prototype: the goal is to make simulation semantics explicit and portable rather than depend on Ruby-specific object patterns.

## Vocabulary

The main terms are intentionally narrow:

| Term | Meaning |
| --- | --- |
| `App` | executable application shell connecting host input, server, and rendering |
| `Server` | authoritative simulation owner |
| `Level` | immutable authored description of one playable area |
| `Terrain` | spatial glyph/passability data inside a Level |
| `Entity` | reusable authored component recipe |
| `Spawn` | Level instruction to instantiate an Entity |
| `InstanceId` | integer identity of one runtime instance |
| `World` | mutable runtime component and relation state |
| `Planner` | derives commands from current read-only state |
| `Resolver` | authoritatively validates and applies commands |
| `Host` | platform-facing boundary such as terminal I/O |

## Repository structure

The outer Ruby layout is conventional and deliberate:

```text
bin/sunbird          executable
lib/sunbird.rb       library entry point
lib/sunbird/         implementation namespace
```

Root domain types live directly under `lib/sunbird/`:

```text
lib/sunbird/
  server.rb
  level.rb
  world.rb
  entity.rb
```

Supporting code is grouped below those roots:

```text
server/
level/
world/
entity/
```

This avoids redundant paths such as `server/server.rb` and `world/world.rb` while keeping normal Ruby packaging conventions.

## Level and World

`Level` and `World` have different lifetimes and responsibilities.

```text
             authored / immutable
                    |
                    v
                  Level
            /       |       \
       Terrain    Spawns   Relations
                    |
                 instantiate
                    |
                    v
                  World
             mutable / runtime
```

### Level

A `Level` is the complete immutable authored area presented to the simulation. It owns:

- a name;
- `Terrain`;
- keyed `Spawn` descriptions;
- static authored relations;
- the key of the currently controlled spawn.

`Level::Terrain` owns only spatial terrain concerns:

```text
width
height
glyph lookup
bounds
passability
```

The `Level` delegates common spatial queries such as `passable?` and `glyph_at` to its terrain so callers do not need to know how terrain is stored.

### World

`World` is the mutable runtime state produced when a level is instantiated. It owns:

- integer `InstanceId`s;
- component tables;
- runtime relations.

Conceptually:

```text
positions[instance_id]
health[instance_id]
renderables[instance_id]
behaviors[instance_id]
collisions[instance_id]
```

Runtime identity is the integer `InstanceId`. The `:entity_ref` component records which authored entity definition an instance came from; it is not the instance's identity.

## Entities, spawns, and runtime instances

`Entity` is a reusable component recipe stored in `Entity::Catalog`.

A level does not duplicate those components. It stores keyed spawns:

```text
Spawn(
  key: :goblin_a,
  entity: :goblin,
  x: 35,
  y: 3
)
```

Loading creates runtime instances:

```text
Entity(:goblin)
      +
Spawn(:goblin_a)
      |
      v
InstanceId 1
      |
      +-- EntityRef(:goblin)
      +-- Position(...)
      +-- Health(...)
      +-- Behavior(...)
      +-- Collision(...)
```

Spawn keys are authoring identifiers. They are resolved to integer InstanceIds when the server instantiates the level.

## Static and runtime relations

Relations exist in two forms.

Authored level relations reference spawn keys:

```text
targets(:goblin_a, :player)
```

During level instantiation the server resolves those keys:

```text
:player    -> InstanceId 0
:goblin_a  -> InstanceId 1
```

and stores a runtime world relation:

```text
targets(1, 0)
```

This keeps content authoring stable while runtime systems operate only on integer instance IDs.

The server does not contain special rules such as "all goblins target the player." Those relationships are authored in the level.

## Controlled instance

The current prototype has one input-controlled instance.

Rather than searching for an entity named `:player`, the level names a `controlled_spawn` key. The server resolves that spawn key to `controlled_id` when loading the level.

This keeps the server generic with respect to entity names while preserving the simple single-controller model needed by the prototype.

## World::View

Planning code reads runtime state through `World::View`.

The view exposes:

```text
instance?
instance_ids
component
relation_targets
```

but not mutation operations such as `set_component` or `add_relation`.

This is the main read/write authority boundary inside the simulation.

## Authoritative tick

A tick is an operation, not a stored Tick object.

```text
Input::Snapshot
      |
      v
Server#tick
      |
      +--> Planner
      |       |
      |       +--> Relevance
      |       +--> Level
      |       +--> World::View
      |       +--> runtime relations
      |       +--> behavior
      |       +--> Pathfinder
      |       |
      |       v
      |   Commands::Buffer
      |
      +--> Resolver
      |       |
      |       v
      |     World
      |
      +--> increment tick number
```

`Server#tick` remains intentionally small.

## Planner

`Planner` replaces the older `TickBuilder` name. It does not construct a Tick object; it plans commands for the current tick.

Its inputs are:

```text
Input::Snapshot
Level
World::View
controlled_id
Relevance
Pathfinder
```

It produces `Commands::Buffer`.

The current behavior kinds are:

```text
:idle
:wander
:chase
```

Player control and NPC behavior both end in the same command pipeline.

## Relevance

`Server::Relevance` replaces the older `Activation` name.

Its purpose is to answer which runtime instances matter to the current planning pass. The v0.3 policy still returns every instance.

The boundary exists so future spatial/visibility/sleep policies can be introduced without changing `Server#tick` or `Planner` ownership.

## Movement

`Server::Movement` contains the shared definition of whether a cell is currently traversable:

```text
Level terrain passability
        +
blocking runtime Collision components
        =
traversable cell
```

Both Pathfinder and Resolver use this rule.

This removes the v0.2 duplication where pathfinding and authoritative movement resolution independently implemented blocking checks.

Sharing the rule does not make Pathfinder authoritative. Planner sees a snapshot; Resolver checks the same rule again against the current mutable World when applying the command.

## Pathfinder

The current terrain has uniform movement cost, so `Server::Pathfinder` uses breadth-first search.

For chase behavior it:

1. reads source and target positions;
2. finds traversable cells adjacent to the target;
3. searches for a shortest route to one of them;
4. returns only the next cardinal step.

```text
Level
  +
World::View
  +
Movement
  |
  v
Pathfinder
  |
  v
next (dx, dy)
```

There is no multi-agent path reservation. Multiple instances may plan the same destination from the same pre-resolution snapshot; sequential Resolver order decides which movement actually succeeds.

## Commands

Commands represent intent rather than mutation.

Current command types are:

```text
Move(instance_id, dx, dy)
Attack(attacker_id, target_id, damage)
```

`Commands::Buffer` groups the commands planned for one tick.

## Resolver

`Resolver` is the authoritative command application boundary.

### Move

A move is applied only if the destination is still traversable when the command is resolved.

### Attack

Planner may emit an attack when two instances appear adjacent. Resolver checks adjacency again before applying damage.

This fixes an authority hole from v0.2d where a target could theoretically move away earlier in the same tick while a previously planned attack still landed.

The rule remains:

```text
Planner = proposed intent
Resolver = authoritative legality + mutation
```

## Input boundary

Physical terminal input remains outside simulation authority:

```text
TerminalInput
      |
      v
Input::Mapper
      |
      v
Action
      |
      v
Input::Handoff
      |
      v
Input::Snapshot
      |
      v
Server#tick
```

The renamed `Host::TerminalInput` is a platform adapter, not a simulation listener.

## Rendering

Rendering remains outside the server simulation:

```text
Server.level + Server.world_view
              |
              v
       Render::Projector
              |
              v
         Render::Frame
              |
              v
         Render::Ascii
              |
              v
        Host::Terminal
```

Rendering never mutates World.

## Content boundary

Authored Ruby files currently live under:

```text
content/entities/
content/levels/
```

They are temporary source representations behind loaders. `content/` is deliberately separate from `lib/` because it represents game content rather than engine implementation.

The current Ruby constant-loading mechanism is scaffolding, not the intended long-term persistence format.

## v0.3 scope

Version 0.3 is primarily a structural normalization release. Its important changes are:

- `server/server.rb` -> `server.rb`;
- `world/world.rb` -> `world.rb`;
- `TickBuilder` -> `Planner`;
- `Activation` -> `Relevance`;
- `Entity::Registry` -> `Entity::Catalog`;
- `World::Identity` -> `World::EntityRef`;
- `RuntimeRelations` -> `Relations`;
- `Level::Map` -> `Level::Terrain`;
- removal of `Level::Loaded`;
- `Level` becomes the complete authored area object;
- static relations move into Level data;
- server no longer hardcodes goblin/player relation setup;
- pathfinding and Resolver share movement rules;
- attack legality is rechecked authoritatively;
- `CommandBuffer` becomes `Commands::Buffer`;
- `TerminalListener` -> `TerminalInput`;
- `content/entities/core.rb` -> `actors.rb`.

## Deferred systems

Sunbird still deliberately does not implement:

- weighted navigation or A*;
- path caching/navigation meshes;
- crowd reservation/coordination;
- death/removal lifecycle;
- inventory/equipment;
- selective relevance/sleep policies;
- wall-clock simulation pacing;
- background scheduling;
- compiled binary level/content data;
- graphical rendering;
- networking;
- multithreaded simulation.

Those remain later design problems rather than hidden complexity inside the v0.3 cleanup.
