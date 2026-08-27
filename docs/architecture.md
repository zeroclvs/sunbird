# Sunbird v0.2c Architecture

Sunbird is a small experimental RPG engine built around an authoritative, tick-based simulation.

The current Ruby implementation is intended to explore the architecture quickly while keeping the core model portable to lower-level systems languages later.

## Core principles

Sunbird currently follows a few basic rules:

* runtime instances are identified by integer IDs;
* game state is stored in component tables rather than object hierarchies;
* reusable `Entity` definitions are separate from runtime instances;
* `Level` data is treated as immutable environment data;
* `World` contains mutable runtime state;
* only the server domain advances authoritative simulation state;
* player input and NPC behavior produce commands rather than mutating the world directly;
* rendering reads simulation state but does not modify it.

## Server authority

`Server` owns the authoritative runtime simulation.

The public operation that advances the game is:

```text
Server#tick(input)
```

A tick is an operation, not a stored `Tick` object.

Current flow:

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
      |       +--> player / NPC behavior
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

`Server#tick` should remain small.

Planning complexity belongs primarily in `TickBuilder`, while authoritative mutation is performed through `Resolver`.

## Entity definitions and runtime instances

`Entity` represents a reusable content definition.

For example, the goblin definition contains default components such as:

```text
:goblin

Health
Renderable
Behavior(:chase)
Collision
```

A level does not repeat those values for every goblin. It stores a `Spawn`:

```text
Spawn(
  entity: :goblin,
  x: 14,
  y: 10
)
```

When the server loads the level:

```text
Entity definition
       +
Spawn
       |
       v
runtime instance
       |
       v
InstanceId
```

`InstanceId` is the conceptual name for the integer used to index runtime component tables.

Different instances created from the same `Entity` definition have independent mutable runtime state.

## World

`World` owns mutable runtime simulation data.

Current component storage is array-backed and indexed by runtime instance ID.

Conceptually:

```text
positions[instance_id]
health[instance_id]
renderables[instance_id]
behaviors[instance_id]
collisions[instance_id]
```

The implementation deliberately avoids game-object inheritance hierarchies.

An instance's meaning comes from its components and relations.

### World::View

External server planning code normally reads runtime state through `World::View`.

The view exposes queries such as:

```text
instance IDs
components
relation targets
```

but does not expose mutation operations such as `set_component`.

This maintains a clear distinction between observation and authoritative mutation.

## Runtime relations

Relations are first-class runtime data stored with `World`.

v0.2c currently uses a simple relation representation:

```text
kind
source_id
target_id
```

The first implemented relation is:

```text
targets(goblin, player)
```

At level initialization the server establishes a target relation from each goblin instance to the player instance.

Relations are queried through `World::View` during planning.

Current relation storage is intentionally simple and unoptimized.

## TickBuilder

`TickBuilder` is the planning side of the server tick.

Its job is to inspect the current simulation state and produce intent.

Current inputs include:

```text
Input::Snapshot
Level
World::View
Activation
runtime relations
```

It iterates over active instances and decides what command, if any, each instance should produce.

### Player

Player input is translated into a movement command:

```text
Input::Snapshot
      |
      v
player_move
      |
      v
Move(instance, dx, dy)
```

### NPC behavior

NPC instances carry a `Behavior` component.

Current behavior kinds include:

```text
:idle
:wander
:chase
```

Behavior code produces the same command types used by player input.

This keeps decision-making separate from mutation:

```text
player input -----+
                  |
NPC behavior -----+--> CommandBuffer --> Resolver --> World
```

## Chase behavior

In v0.2c goblins use their `:targets` relation to find the player.

The current chase algorithm is intentionally primitive:

1. read the target relation;
2. read goblin and target positions;
3. move one tile toward the target;
4. prefer the X axis while X differs;
5. otherwise move on the Y axis.

Example:

```text
G . . P
```

produces:

```text
Move(goblin, +1, 0)
```

The chase planner does not check whether that move will succeed.

That responsibility remains with `Resolver`.

As a result, goblins can currently become stuck behind:

* water;
* walls;
* another blocking instance.

There is no pathfinding or obstacle avoidance in v0.2c.

These limitations are intentional and useful for evaluating later planning changes.

## Commands and resolution

Commands represent simulation intent.

The current primary command is:

```text
Move(instance, dx, dy)
```

`TickBuilder` produces commands but does not mutate `World`.

`Resolver` applies them under server authority.

For movement it currently checks:

```text
destination inside/passable terrain?
        |
        v
destination occupied by blocking instance?
        |
        v
replace Position
```

Terrain collision therefore belongs to `Level`, while dynamic occupancy is determined from `World`.

Sequential command resolution means runtime instance order can currently affect competing movement attempts.

## Activation

`Server::Activation` determines which runtime instances participate in the current planning pass.

The current implementation simply activates every instance:

```text
World instances
      |
      v
Activation
      |
      v
all InstanceIds
```

Activation is intentionally a policy boundary.

It is not yet defined in terms of distance, visibility, pathfinding, rooms, or line of sight.

A more selective policy can be introduced later without changing the meaning of `Server#tick`.

## Level and World

Sunbird keeps immutable environment data separate from mutable simulation state.

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
  behavior state
  runtime relations
```

The current Ruby level and entity files are temporary source representations behind loaders.

They are not intended to define the eventual persistent engine format.

## Input boundary

Physical input remains outside the authoritative simulation.

Current flow:

```text
terminal key
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

The server never needs to understand terminal escape sequences or physical key codes.

Input is event-driven outside the server and stable for the duration of each tick.

## Rendering

Rendering is outside the server simulation domain.

Current path:

```text
Server.world_view + Server.level
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

Rendering does not mutate `World`.

The ASCII renderer is a replaceable presentation layer rather than part of the simulation architecture.

## Current scope

Sunbird v0.2c currently demonstrates:

```text
reusable Entity definitions
        |
        v
level Spawns
        |
        v
runtime instances
        |
        +--> components
        |
        +--> runtime relations
                  |
                  v
              TickBuilder
                  |
        +---------+---------+
        |                   |
    player input         NPC behavior
        |                   |
        +---------+---------+
                  |
                  v
             CommandBuffer
                  |
                  v
               Resolver
                  |
                  v
                World
```

Systems deliberately not implemented yet include:

* pathfinding;
* combat;
* inventory;
* background scheduling;
* selective activation;
* fixed real-time tick pacing;
* compiled binary level data;
* VFS;
* graphical rendering;
* networking;
* multithreaded simulation.

The current priority is to understand and refine the simulation architecture before adding those systems.
