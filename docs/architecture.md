# Sunbird v0.3b Architecture

Sunbird v0.3b is a small game-runtime foundation with two presentation backends: ASCII and Kitty terminal graphics. It retains explicit runtime state, command intent, authoritative resolution, mode-owned advancement policy, and strict presentation separation.

The Ruby program remains an architecture prototype rather than a commitment to Ruby-specific object patterns.

## Vocabulary

| Term | Meaning |
| --- | --- |
| `App` | executable shell connecting input, modes, rendering, and the host |
| `Session` | owns persistent game state that survives level-local Simulation/World lifetimes |
| `Party` | persistent roster of stable party-member identities and the current leader |
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
| `AssetCatalog` | maps semantic render keys to renderer assets |
| `Host` | platform/terminal I/O and capability boundary |

## Runtime domains

```text
App
 |
Session
 |
ModeStack
 |
Active Mode
 |
Simulation
 |-- Planner
 |-- Resolver
 |-- Movement
 |-- Pathfinder
 `-- World
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

Terrain carries both a semantic `render_key` and an ASCII fallback glyph. Gameplay consumes passability; presentation consumes render identity.

World owns level-local mutable runtime state such as position, health, behavior, collision, and runtime relations. `Session` now sits above that lifetime and owns a `Party` roster made of stable member identities. Session deliberately does not store World `InstanceId`s. Persistent actor statistics such as HP/MP/equipment are not modeled yet, so v0.3b avoids creating competing authoritative copies of those values.

## Simulation is not a clock

The core operations remain:

```text
Simulation#plan(input:, controlled_id:)
Simulation#step(commands:)
```

`plan` reads Level + `World::View` through Planner and returns `Commands::Buffer`. It does not mutate World. The current mode supplies the runtime `controlled_id`; Simulation no longer owns a permanent player/control identity.

`step` consumes explicit commands, asks Resolver to validate/apply them, and increments `step_number`.

Planner is one command producer, not a mandatory universal engine loop. Battle logic, scripts, cutscenes, tests, or networking can later produce commands through another boundary.

A **step** is one authoritative state transition; it says nothing about wall-clock cadence.

## Modes own advancement policy

`App` owns a persistent `Session` plus a `ModeStack`. The current `Mode::Exploration` advances after actionable input and binds `Session#party.leader` to the Level `entry_spawn` for the lifetime of that loaded simulation. Other party members may exist in Session without having a World instance. A JRPG battle mode can later consume the whole party, while a future metroidvania mode can drive steps from a fixed-step scheduler.

The common Simulation layer does not choose that policy.

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

## Render::Scene

Projection is backend-neutral:

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

Stable instance IDs remain available for later presentation interpolation. v0.3a does not add interpolation or an independent render clock.

## Render backends

v0.3a has two Scene consumers:

```text
                  Render::Scene
                   /          \
                  /            \
         Render::Ascii      Render::Kitty
              |                  |
      fallback glyphs       AssetCatalog
                                 |
                              PNG files
```

### ASCII

ASCII remains the reference/fallback renderer. It is deliberately retained even when Kitty graphics are available because it is useful for debugging, basic terminals, and renderer-independent verification.

### Kitty

`Render::Kitty` implements the first graphical terminal backend. It:

- maps Scene `render_key` values through `Render::AssetCatalog`;
- transmits each unique PNG once per renderer lifetime as direct PNG data;
- owns Kitty image IDs internally rather than storing protocol IDs in the asset catalog;
- assigns stable placement IDs to terrain cells and runtime instances;
- keeps unchanged placements on screen, replaces moved instances in place, and deletes only placements that disappear;
- places each logical tile over two terminal columns by one row to better approximate square tiles on common terminal fonts;
- gives terrain a lower z-index than runtime instances;
- deletes its owned image data when the renderer closes;
- falls back to a Scene item's glyph if an asset key is absent.

The first renderer is intentionally static: no animation, atlas, interpolation, camera, or asset streaming exists yet.

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
```

This is renderer-facing data, not a general VFS or asset pipeline.

## Host boundary and capability detection

Renderer and Host responsibilities remain separate. The Host also owns terminal-screen lifecycle (alternate screen, cursor state, synchronized-update controls), while each renderer declares whether it needs a destructive clear before a frame:

```text
Renderer = how Scene becomes presentation
Host     = how output/input reaches the terminal
```

`Host::TerminalCapabilities` continues to perform conservative Kitty environment detection using Kitty's terminal environment (`KITTY_WINDOW_ID` or a Kitty `TERM` value). It reports:

```text
graphics_protocol: :kitty | nil
keyboard_protocol: :legacy
```

Terminal input remains deliberately protocol-light in v0.3b. `Host::Terminal` owns raw mode for the entire application session and restores the previous console mode on exit. `TerminalInput` decodes ordinary WASD/Q input plus legacy CSI/SS3 arrow sequences, treats a standalone Escape as an event using a short continuation timeout, and maps raw Ctrl-C to quit. Sunbird does not enable Kitty's enhanced press/repeat/release keyboard reporting in this branch; that richer physical-input model is deferred to the Raylib host planned for v0.4.

The environment variable `SUNBIRD_RENDERER` can override renderer selection:

```text
auto   default; follow detected capability
ascii  force ASCII
kitty  force Kitty graphics
```

The explicit Kitty override is also the escape hatch for compatible terminals not recognized by this first conservative detector. A later terminal-input/protocol pass can replace environment hints with a full active protocol query without changing Renderer or Scene APIs.

## Content boundary

Authored Ruby content remains under `content/entities/` and `content/levels/`. `Entity::Loader` and `Level::Loader` continue to share temporary Ruby source-file plumbing through `Content::RubySource`.

The Ruby content representation is scaffolding, not the intended long-term persistence format.

## v0.3b scope

v0.3b preserves the v0.3a graphical presentation path, keeps terminal input deliberately small, and establishes the first persistent JRPG-facing state above the level-local simulation:

- persistent `Session` owned by `App`;
- `Party` roster with stable member identities and a leader;
- exploration-time binding from party leader to Level `entry_spawn`;
- `Simulation#instance_id_for_spawn` as an explicit authored-spawn/runtime-instance bridge;
- `Level#controlled_spawn` renamed to `Level#entry_spawn`, so Level no longer owns control policy;
- persistent raw terminal mode owned by `Host::Terminal`;
- safe standalone Escape handling and variable-length legacy arrow decoding;
- Q/Escape/Ctrl-C quit handling;
- no enhanced Kitty keyboard event framework;
- conservative Kitty graphics capability detection;
- automatic ASCII/Kitty renderer selection;
- renderer override through `SUNBIRD_RENDERER`;
- a tiny PNG `AssetCatalog`;
- default placeholder sprites/tiles under `content/sprites/`;
- `Render::Kitty` consuming the existing backend-neutral Scene;
- persistent Kitty placements with stable placement IDs and synchronized redraws;
- alternate-screen application lifecycle without per-frame Kitty `CSI 2J` clears;
- cleanup of image placements/data owned by the renderer;
- ASCII fallback preserved with its existing full-redraw policy;
- version/docs/tests updated.

Explicitly deferred:

- enhanced Kitty press/repeat/release keyboard protocol;
- active graphics-protocol query for unknown terminals;
- sprite animation;
- interpolation or independent presentation cadence;
- camera/viewport scrolling;
- sprite atlases or asset streaming;
- JRPG battle/menu/dialogue systems;
- persistent actor statistics (HP/MP/equipment) and save serialization;
- fixed-step metroidvania scheduling;
- Raylib or 3D rendering.
