# Sunbird v0.2b

Sunbird is an experimental tick-based RPG simulation engine
prototyped in Ruby.

Version 0.2 reorganizes the day-one prototype around a clearer
single-process client/server authority model inspired by Quake.

## Core model

The important runtime boundary is:

```text
input / presentation
        |
        v
Server#tick
        |
        +--> TickBuilder
        |       |
        |       +--> Activation
        |       +--> World::View
        |       +--> Level
        |       +--> input snapshot
        |       |
        |       v
        |   CommandBuffer
        |
        +--> Resolver
                |
                v
              World
```

`Server#tick` is the single authoritative operation that advances
simulation state. `TickBuilder` reads the structures needed to plan
work. `Resolver` performs mutations under server authority.

There is deliberately no `Tick` data record in v0.2.

## Terminology

### Entity

An `Entity` is now a reusable content definition: a component recipe
such as `:player` or `:goblin`.

```text
:goblin
  renderable
  health
  behavior
  collision
```

### Spawn

A level stores only a placement of an entity definition:

```text
Spawn(entity: :goblin, x: 14, y: 10)
```

### InstanceId

When the server loads a level, each spawn becomes a runtime instance.
The returned non-negative integer is conceptually an `InstanceId`.

Runtime component tables are indexed by InstanceId.

## Activation

The old `Accessibility` name is gone.

`Server::Activation` chooses which runtime instances are active for
the current planning pass. The initial policy simply returns every
instance. A spatial or relational policy can replace it later without
changing `Server#tick`.

## Entity source data

Reusable entity definitions live temporarily in Ruby:

```text
content/entities/core.rb
```

Level source data lives in:

```text
content/levels/test_field.rb
```

Both are temporary source representations behind loaders. The long
term target remains compiled binary level/content data.

## Rendering

Rendering is intentionally unchanged in this revision. It still
projects `World::View + Level` into a frame and then emits ASCII.
The client/server refactor is focused on simulation authority.

## Run

Ruby 3.2+ is required.

```sh
bundle install
bundle exec ruby bin/sunbird
```

Controls:

```text
W / Up Arrow    north
S / Down Arrow  south
A / Left Arrow  west
D / Right Arrow east
Q               quit
```

## Tests

Run all tests:

```sh
bundle exec ruby -Itest -e \
  'Dir["test/*_test.rb"].sort.each { |file| require_relative file }'
```

## Deliberately deferred

Sunbird v0.2 still does not introduce:

- goblin AI;
- runtime relations;
- combat;
- scheduler/timing wheel;
- wall-clock pacing;
- deterministic replay;
- threads or Ractors;
- VFS;
- binary level compiler;
- SDL/raylib;
- an ECS framework;
- sparse sets/archetype storage;
- pathfinding;
- networking.

The next useful milestone is to let goblin behavior participate in
`TickBuilder` and produce the same command types as player input.
