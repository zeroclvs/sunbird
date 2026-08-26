# Sunbird v0.2b Architecture

## Authority

The server domain owns authoritative runtime state.

`Server#tick` is the only public operation that advances that state.
Helpers such as `Resolver` may mutate `World`, but only while invoked
under server authority.

The host, input system, renderer, level source data, and external
adapters never mutate `World`.

## Tick

A tick is an operation, not a record.

Current form:

```text
Server#tick(input)
  |
  +--> TickBuilder.build(...)
  |       |
  |       +--> Activation
  |       +--> Level
  |       +--> World::View
  |       +--> input
  |       |
  |       v
  |   CommandBuffer
  |
  +--> Resolver.resolve(...)
  |
  +--> increment tick number
```

`TickBuilder` is where planning complexity is expected to grow.
`Server#tick` should remain small and globally authoritative.

## Entities and instances

`Entity` is reusable content definition.

`Spawn` is a level placement.

`InstanceId` is the conceptual name for the integer returned when an
Entity is instantiated into `World`.

Example:

```text
Entity :goblin
      |
      +--> Spawn(:goblin, 35, 3)
      |        |
      |        v
      |    InstanceId 1
      |
      +--> Spawn(:goblin, 14, 10)
               |
               v
           InstanceId 2
```

Both runtime instances receive the entity's default components but
have independent runtime positions and later independent replaced
component values.

## Current data ownership

```text
Entity source
  immutable reusable component recipe

Level
  immutable terrain + spawn descriptions

World
  mutable runtime component tables

World::View
  read-only query boundary

Input::Snapshot
  stable input for one server tick

CommandBuffer
  intent produced by TickBuilder

Resolver
  authorized command application
```

## Activation

Activation answers:

> Which runtime instances should participate in planning now?

The current implementation activates every instance. It is a policy
boundary, not a distance/visibility/pathfinding definition.

## Rendering

Rendering remains outside server authority:

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
```

No rendering code mutates the server World.
