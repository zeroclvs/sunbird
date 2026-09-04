# Sunbird v0.3 Architecture

Sunbird v0.3 is a small game-runtime foundation. It retains the useful parts of the earlier Quake-inspired prototype—explicit runtime state, command intent, authoritative resolution, and strict presentation separation—without making a global fixed tick the identity of the engine.

The current Ruby program is a prototype for architecture and semantics, not a commitment to Ruby-specific object patterns.

## Vocabulary

| Term | Meaning |
| --- | --- |
| `App` | executable shell connecting input, modes, rendering, and the host |
| `ModeStack` | owns the active application/game mode |
| `Mode` | decides how input/time advances gameplay |
| `Simulation` | owns one loaded Level/World simulation and authoritative command application |
| `Level` | immutable authored description of one playable area |
| `Terrain` | spatial/passability data inside a Level |
| `Entity` | reusable authored component recipe |
| `Spawn` | Level instruction to instantiate an Entity |
| `InstanceId` | integer identity of one runtime instance |
| `World` | mutable level-local component and runtime-relation state |
| `Planner` | optional command producer that derives intent from read-only state |
| `Resolver` | authoritatively validates and applies commands |
| `Scene` | backend-neutral presentation snapshot produced from Level + World::View |
| `Renderer` | converts a Scene into presentation output |
| `Host` | platform/terminal I/O and capability boundary |

## Repository structure

The outer Ruby layout remains conventional:

```text
bin/sunbird          executable
lib/sunbird.rb       library entry point
lib/sunbird/         implementation namespace
```

The main runtime domains are:

```text
lib/sunbird/
  app.rb
  mode_stack.rb
  mode/
  simulation.rb
  simulation/
  level.rb
  level/
  world.rb
  world/
  entity.rb
  entity/
  render/
  host.rb
  host/
```

`Simulation` replaces the earlier `Server` terminology. Networking is not part of the current runtime, and authority is expressed by the Resolver boundary rather than by a client/server name.

## Level and World

`Level` and `World` intentionally have different lifetimes.

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

A `Level` owns:

- a name;
- `Terrain`;
- keyed `Spawn` descriptions;
- static authored relations;
- the key of the currently controlled spawn used by the present exploration prototype.

Terrain now carries a semantic `render_key` as well as the current ASCII glyph. Gameplay uses passability; presentation uses the render key. The glyph is fallback data for the ASCII renderer.

### World

`World` owns level-local mutable runtime state:

```text
positions[instance_id]
health[instance_id]
renderables[instance_id]
behaviors[instance_id]
collisions[instance_id]
```

Runtime identity is the integer `InstanceId`. `EntityRef` records which authored Entity definition produced an instance.

`World` should not automatically become the complete saved-game state. A JRPG branch will likely need persistent session/party state that survives level and mode transitions.

## Entities, spawns, and relations

`Entity::Catalog` stores reusable component recipes. Level spawns use stable authoring keys:

```text
Spawn(key: :goblin_a, entity: :goblin, x: 35, y: 3)
```

Static relations also use spawn keys:

```text
targets(:goblin_a, :player)
```

Simulation instantiation resolves them to runtime InstanceIds and stores runtime relations in World. Simulation contains no special rule such as “goblins target the player.”

## Simulation is not a clock

The earlier architecture centered on `Server#tick`. v0.3 replaces that with two operations:

```text
Simulation#plan(input:)
Simulation#step(commands:)
```

`plan` reads Level + `World::View` through Planner and returns `Commands::Buffer`. It does not mutate the World.

`step` consumes explicit commands, asks Resolver to validate/apply them, and increments `step_number`.

```text
Input::Snapshot
      |
      v
    Planner             another future producer
      |                         |
      v                         v
Commands::Buffer <--------------+
      |
      v
Simulation#step
      |
      v
   Resolver
      |
      v
    World
```

Planner is therefore a command producer, not a mandatory universal engine loop. Battle logic, scripts, cutscenes, tests, or networking can later produce commands through another boundary.

A **step** means one authoritative state transition. It says nothing about wall-clock cadence.

## Modes own advancement policy

`App` owns a `ModeStack`. The active mode decides when gameplay advances.

The current `Mode::Exploration` is action-driven:

```text
physical input
     |
Input::Mapper
     |
Input::Snapshot
     |
ExplorationMode
     |
     +--> quit? -> return to App
     |
     +--> Simulation#plan
              |
              v
        Simulation#step
```

This preserves the current JRPG-like behavior: standing still does not automatically advance the simulation.

A future metroidvania mode can instead call simulation steps from a fixed-step scheduler. A battle mode can advance on turns or another battle-specific policy. The common Simulation layer does not choose between those policies.

## Planner

Planner reads:

```text
Input::Snapshot
Level
World::View
controlled_id
Relevance
Pathfinder
```

and produces commands.

Behavior dispatch is table-driven through `BEHAVIOR_HANDLERS`, keyed by `behavior.kind`. Relations are data consumed by handlers, not another dispatch mechanism.

The current behavior kinds are `:idle`, `:wander`, and `:chase`.

## Relevance, movement, and pathfinding

`Simulation::Relevance` currently selects every runtime instance for planning. It remains a policy seam for later visibility/sleep/spatial selection.

`Simulation::Movement` is the shared definition of traversability:

```text
terrain passability
       +
blocking runtime Collision components
       =
traversable cell
```

Both Pathfinder and Resolver use it. Resolver still rechecks the rule against current mutable state and therefore remains authoritative.

`Simulation::Pathfinder` uses breadth-first search because current movement costs are uniform. There is no multi-agent reservation yet.

## Commands and Resolver

Current commands are:

```text
Move(instance_id, dx, dy)
Attack(attacker_id, target_id, damage)
```

Resolver is the sole mutation/legality boundary for those commands. Movement is rechecked for current traversability. Attack adjacency is rechecked before damage is applied.

The stable rule is:

```text
command producer = proposed intent
Resolver         = authoritative legality + mutation
```

## Render::Scene

The old renderer pipeline collapsed Level/World directly into an ASCII `Frame(lines)`. v0.3 replaces that with a backend-neutral Scene:

```text
Level + World::View
        |
        v
Render::Projector
        |
        v
Render::Scene
   |        |
 tiles   instances
            |
       stable InstanceId
            |
       render_key
       position
       layer
       fallback glyph
```

Scene instance entries retain stable runtime IDs. This is intentional groundwork for future interpolation between presentation snapshots.

The current Scene also carries `fallback_glyph` so the ASCII renderer remains simple and output-compatible. The semantic `render_key` is the identity a graphical renderer should use.

```text
Render::Scene
      |
      +--> Render::Ascii   (current reference backend)
      |
      +--> Render::Kitty   (future)
      |
      +--> other renderer  (future)
```

ASCII should remain a useful fallback/reference renderer even after terminal graphics exist.

## Host boundary

Rendering and Host responsibilities are separate.

Renderer decides **how a Scene is encoded for presentation**. Host owns **platform transport and input**.

Current terminal host:

```text
Host::Terminal
  |- terminal output/lifecycle
  |- input adapter
  `- Capabilities
       |- graphics_protocol
       `- keyboard_protocol
```

The current capabilities report no graphics protocol and legacy keyboard decoding. No Ghostty/Kitty probing is implemented in v0.3.

Future capability detection should detect protocols rather than terminal brand. A Kitty graphics renderer and Kitty keyboard decoder can therefore work across compatible terminals rather than being tied to Ghostty by name.

## Content boundary

Authored Ruby files currently live under:

```text
content/entities/
content/levels/
```

`Entity::Loader` and `Level::Loader` share temporary Ruby source-file validation and constant-name derivation through `Content::RubySource`.

The Ruby constant-based content representation is scaffolding, not the intended long-term persistence/asset format.

## v0.3 foundation

The final v0.3 foundation intentionally establishes these boundaries before choosing a game direction:

- `Server` -> `Simulation`;
- `tick` -> cadence-neutral `step`;
- planning separated from command application (`plan` vs `step`);
- App-level `ModeStack` and action-driven `Exploration` mode;
- Level remains immutable authored area data;
- World remains level-local mutable runtime state;
- explicit command/Resolver authority remains intact;
- semantic render keys are added to terrain and renderable components;
- ASCII-specific `Render::Frame` is replaced by `Render::Scene`;
- Scene entries retain stable runtime instance IDs;
- Host owns terminal I/O/capabilities while Renderer owns presentation encoding;
- ASCII remains the reference/fallback renderer;
- no Kitty graphics, Kitty keyboard protocol, fixed-step scheduler, interpolation, battle system, or persistent party/session model is implemented yet.

This lets later branches choose different advancement policies without forking the underlying Level/World/command/render boundaries.
