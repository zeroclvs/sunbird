# Sunbird v0.3c Architecture

Sunbird v0.3c is a small game-runtime foundation targeting Kitty terminal graphics. It retains explicit runtime state, command intent, authoritative resolution, mode-owned advancement policy, and strict presentation separation, while adding the first minimal JRPG interaction and dialogue flow.

The Ruby program remains an architecture prototype rather than a commitment to Ruby-specific object patterns.

## Vocabulary

| Term | Meaning |
| --- | --- |
| `App` | executable shell connecting input, modes, rendering, and the host |
| `Session` | owns persistent game state that survives level-local Simulation/World lifetimes |
| `Party` | persistent roster of stable party-member identities and the current leader |
| `ModeStack` | owns the active application/game mode |
| `Mode` | decides how input/time advances gameplay |
| `Exploration` | mode that binds party control, advances local simulation, and handles interaction policy |
| `Dialogue` | mode that consumes dialogue input while leaving exploration simulation suspended |
| `Simulation` | owns one loaded Level/World simulation and authoritative command application |
| `Level` | immutable authored description of one playable area |
| `Terrain` | spatial/passability data inside a Level |
| `Entity` | reusable authored component recipe |
| `Spawn` | Level instruction to instantiate an Entity |
| `InstanceId` | integer identity of one runtime instance |
| `World` | mutable level-local component and runtime-relation state |
| `Facing` | runtime component storing one cardinal interaction direction |
| `Interactable` | runtime component referencing authored dialogue through a dialogue key |
| `Planner` | optional command producer that derives intent from read-only state |
| `Resolver` | authoritatively validates and applies commands |
| `Scene` | backend-neutral presentation snapshot produced from Level + World::View |
| `Renderer` | converts a Scene into presentation output |
| `AssetCatalog` | maps semantic render keys to renderer assets |
| `Host` | platform/terminal I/O and capability boundary |

## Runtime domains

```text
App
 |
Session
 |
ModeStack
 |-- Exploration
 |     |
 |     `-- Simulation
 |          |-- Planner
 |          |-- Resolver
 |          |-- Movement
 |          |-- Pathfinder
 |          `-- World
 |
 `-- Dialogue
       |
       `-- references suspended Exploration state
```

The outer Ruby layout remains conventional:

```text
bin/sunbird          executable
lib/sunbird.rb       library entry point
lib/sunbird/         implementation namespace
```

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

Terrain carries a semantic `render_key` plus legacy fallback-glyph metadata. Gameplay consumes passability; active v0.3c presentation consumes render identity.

World owns level-local mutable runtime state such as position, health, behavior, collision, facing, interactability, and runtime relations. `Session` sits above that lifetime and owns a `Party` roster made of stable member identities. Session deliberately does not store World `InstanceId`s.

Persistent actor statistics such as HP/MP/equipment are not modeled yet, so v0.3c avoids creating competing authoritative copies of those values.

## Simulation is not a clock

The core operations remain:

```text
Simulation#plan(input:, controlled_id:)
Simulation#step(commands:)
```

`plan` reads Level + `World::View` through Planner and returns `Commands::Buffer`. It does not mutate World. The current mode supplies the runtime `controlled_id`; Simulation does not own a permanent player/control identity.

`step` consumes explicit commands, asks Resolver to validate/apply them, and increments `step_number`.

Planner is one command producer, not a mandatory universal engine loop. Battle logic, scripts, cutscenes, tests, or networking can later produce commands through another boundary.

A **step** is one authoritative state transition; it says nothing about wall-clock cadence.

## Modes own advancement policy

`App` owns a persistent `Session` plus a `ModeStack`.

`Mode::Exploration` advances after movement input and binds `Session#party.leader` to the Level `entry_spawn` for the lifetime of that loaded simulation. Other party members may exist in Session without having a World instance.

v0.3c makes `ModeStack` operational as more than a single-mode holder:

```text
Exploration
    |
    | interact with adjacent entity
    v
Mode::Push(Dialogue)
    |
    v
Dialogue
    |
    | final line / cancel
    v
:pop
    |
    v
Exploration
```

`App` owns the actual stack mutation. Modes return transition intent rather than directly reaching into the application shell.

Dialogue exposes the same Level and `World::View` as its suspended parent Exploration mode so the existing scene remains visible. Dialogue input changes only dialogue-local state; it does not call `Simulation#plan` or `Simulation#step`.

The common Simulation layer does not choose mode policy.

## Facing and interaction

The player entity now carries:

```text
Facing(direction)
```

with one of:

```text
:north
:south
:east
:west
```

Resolver updates facing before validating whether a Move command can enter the destination tile. This means an attempted move into a blocking NPC still turns the player toward that NPC while preserving Resolver authority over movement.

Interaction remains gameplay policy in `Mode::Exploration`, not a Simulation mutation.

Conceptually:

```text
controlled party instance
        |
        v
Position + Facing
        |
        v
adjacent tile
        |
        v
Interactable instance?
        |
        v
dialogue_key
        |
        v
Dialogue::Catalog
        |
        v
Mode::Push(Dialogue)
```

An interaction with no adjacent `Interactable` returns without advancing the simulation.

## Dialogue content

Authored dialogue lives under:

```text
content/dialogue/
```

`Dialogue::Loader` reuses the existing `Content::RubySource` convention, and `Dialogue::Catalog` validates a small mapping from dialogue keys to non-empty arrays of strings.

The first representation is deliberately limited:

```text
dialogue_key -> ordered lines
```

There are no branches, choices, conditions, scripts, portraits, localization rules, or persistent dialogue flags yet.

## Planner, movement, and pathfinding

Behavior dispatch remains table-driven through `BEHAVIOR_HANDLERS`, keyed by `behavior.kind`. Relations are data consumed by handlers rather than another dispatch mechanism.

`Simulation::Movement` is the shared definition of traversability used by Pathfinder and Resolver. Resolver still rechecks legality against current mutable state and remains authoritative.

`Simulation::Pathfinder` uses breadth-first search because current movement costs are uniform. There is still no multi-agent reservation.

## Commands and Resolver

Current commands are:

```text
Move(instance_id, dx, dy)
Attack(attacker_id, target_id, damage)
```

The stable rule remains:

```text
command producer = proposed intent
Resolver         = authoritative legality + mutation
```

Facing is updated as part of Move resolution before destination traversability is checked. No separate Interact command exists in v0.3c because interaction currently changes mode/application state rather than authoritative World state.

## Render::Scene

Projection remains backend-neutral:

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

Stable instance IDs remain available for later presentation interpolation. Fallback glyph metadata is retained as legacy/reference data, but it is not part of the active v0.3c runtime renderer selection.

Dialogue does not yet add a generic UI-overlay layer to `Render::Scene`. `Mode::Dialogue#status_text` is displayed through the existing terminal status row while the projected level scene remains visible.

## Active render backend

The active v0.3c presentation path is:

```text
Render::Scene
      |
      v
Render::Kitty
      |
      v
AssetCatalog
      |
      v
PNG files
```

`Render::Kitty`:

- maps Scene `render_key` values through `Render::AssetCatalog`;
- transmits each unique PNG once per renderer lifetime as direct PNG data;
- owns Kitty image IDs internally rather than storing protocol IDs in the asset catalog;
- assigns stable placement IDs to terrain cells and runtime instances;
- keeps unchanged placements on screen, replaces moved instances in place, and deletes only placements that disappear;
- places each logical tile over two terminal columns by one row;
- gives terrain a lower z-index than runtime instances;
- deletes its owned image data when the renderer closes;
- can still use a Scene item's fallback glyph when an asset key is absent.

The renderer remains intentionally static: no animation, atlas, interpolation, camera, or asset streaming exists yet.

`Render::Ascii` remains in the source tree as inactive legacy/reference code from the v0.3a dual-renderer period. v0.3c does not select it at runtime. The historically maintained dual ASCII/Kitty state is preserved in v0.3a.

## Asset catalog

`Render::AssetCatalog` is intentionally small. It maps semantic render identities to PNG files. Kitty protocol image and placement IDs belong to `Render::Kitty`, not to asset metadata.

Default assets live under:

```text
content/sprites/
```

Current keys are:

```text
:ground
:grass
:water
:wall
:player
:goblin
:villager
```

This is renderer-facing data, not a general VFS or asset pipeline.

## Host boundary and capability detection

Renderer and Host responsibilities remain separate:

```text
Renderer = how Scene becomes presentation
Host     = how output/input reaches the terminal
```

`Host::Terminal` owns terminal-screen lifecycle, synchronized-update controls, and persistent raw input mode.

`Host::TerminalCapabilities` performs conservative Kitty environment detection using `KITTY_WINDOW_ID` or a Kitty `TERM` value. It reports:

```text
graphics_protocol: :kitty | nil
keyboard_protocol: :legacy
```

v0.3c requires `graphics_protocol: :kitty`. If it is unavailable, renderer construction fails immediately with a clear unsupported-terminal error rather than silently choosing ASCII.

Terminal input remains deliberately protocol-light. `TerminalInput` decodes ordinary WASD/Q input plus Enter, Space, legacy CSI/SS3 arrow sequences, standalone Escape, and raw Ctrl-C.

`Input::Mapper` maps Enter/Space to `:interact`, Escape to `:cancel`, and Q/Ctrl-C to quit behavior. Exploration treats cancel as application quit; Dialogue treats cancel as a mode pop.

Sunbird does not enable Kitty's enhanced press/repeat/release keyboard reporting in this branch.

## Content boundary

Authored Ruby content remains under:

```text
content/entities/
content/levels/
content/dialogue/
```

`Entity::Loader`, `Level::Loader`, and `Dialogue::Loader` use the same temporary Ruby source-file convention through `Content::RubySource`.

The Ruby content representation is scaffolding, not the intended long-term persistence format.

## v0.3c scope

v0.3c builds directly on the v0.3b Session/Party and Kitty foundation and adds a deliberately minimal interaction/dialogue vertical slice:

- `Facing` runtime component with four cardinal directions;
- facing changes even when a Move is blocked;
- `Interactable(dialogue_key)` runtime component;
- Enter/Space interaction input;
- contextual Escape behavior through `:cancel`;
- adjacent-facing interaction lookup in `Mode::Exploration`;
- authored `Dialogue::Catalog` and `Dialogue::Loader`;
- one villager and one two-line conversation in the test level;
- `Mode::Dialogue`;
- explicit `Mode::Push` transition intent;
- `App`-owned ModeStack push/pop application;
- dialogue leaves the exploration scene visible;
- dialogue does not advance the Simulation;
- Kitty villager asset and default asset-catalog coverage.

Explicitly deferred:

- dialogue branching, choices, conditions, scripting, portraits, and persistent conversation flags;
- general Scene/UI overlay system;
- JRPG battle/menu systems;
- persistent actor statistics (HP/MP/equipment) and save serialization;
- enhanced Kitty press/repeat/release keyboard protocol;
- active graphics-protocol query for unknown terminals;
- sprite animation;
- interpolation or independent presentation cadence;
- camera/viewport scrolling;
- sprite atlases or asset streaming;
- fixed-step metroidvania scheduling;
- Raylib or 3D rendering.
