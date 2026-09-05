# Sunbird

Sunbird is an experimental game-runtime foundation written in Ruby.

It is a research/prototype implementation for exploring small data-oriented game architecture while keeping simulation, gameplay policy, persistent state, presentation, and host I/O explicit. The v0.3 line targets Kitty terminal graphics and a compact JRPG-style vertical slice.

**Current version:** `v0.3d`

## Current state

Sunbird v0.3d includes:

- integer runtime instance IDs and array-backed component storage;
- immutable authored `Level` data and mutable level-local `World` state;
- persistent `Session` state with a `Party` roster and stable member identities;
- Session-owned persistent HP/MP (`Session::Vitals`) for party members;
- authored spawn-key relations resolved to runtime instance relations;
- explicit `Move`, `Attack`, and `Defeat` commands with authoritative World resolution;
- table-driven NPC behavior, BFS pathfinding, collision, movement, and attacks;
- `ModeStack` with Exploration, Dialogue, and Battle modes;
- facing state and adjacent-tile interaction;
- authored dialogue content referenced through `Interactable` components;
- visible combat encounters entered from Exploration;
- persistent party damage across battle exit/re-entry;
- backend-neutral `Render::Scene` projection;
- semantic PNG assets and persistent Kitty image placements;
- persistent raw terminal input with WASD, arrows, Enter/Space, Escape, Q, and Ctrl-C handling.

The current test field contains a player, a villager, and goblins. The player can explore, talk to the villager, enter battle with an adjacent goblin, flee, or defeat it. A defeated goblin is retired from rendering, collision, behavior, and combat while its zero HP remains in local runtime state.

## State ownership in v0.3d

v0.3d intentionally establishes only a **partial persistent/local split**:

```text
Session
├── Party
└── Vitals
    ├── :hero  HP / MP
    └── :mage  HP / MP

Level
└── authored immutable area data

World
├── local runtime instances
├── positions / facing / collision
├── NPC behavior and relations
├── enemy Health
└── Combatant attack values
```

The controlled player's World instance deliberately has **no `World::Health`**. Party HP/MP live only in Session, avoiding mirrored authoritative copies.

Enemy HP remains level-local in World. Player attack power is still represented by the World `Combatant` component, and BattleMode currently applies enemy retaliation directly through `Session#damage`. Those are known transitional boundaries, not the final state model.

The planned v0.4 redesign will revisit the naming and responsibilities of `World`, `Session`, persistent actor state, runtime bindings, and mutation authority. See [`docs/v0.4-state-model-proposal.md`](docs/v0.4-state-model-proposal.md).

## Modes

```text
                    App
                     |
                  Session
                     |
                 ModeStack
              /      |      \
     Exploration  Dialogue  Battle
          |
      Simulation
     /          \
Planner        Resolver
   |               |
   v               v
Commands::Buffer -> World
                    |
               World::View
                    |
                    v
           Render::Projector
                    |
                    v
             Render::Scene
                    |
                    v
             Render::Kitty
                    |
                    v
             Host::Terminal
```

A simulation **step is a state transition, not a clock tick**. The active mode decides when a step occurs.

Exploration advances the local simulation. Dialogue suspends it. Battle produces explicit World commands for player attacks and enemy defeat, while persistent party damage is applied to Session-owned vitals.

## Rendering

The active v0.3d path remains Kitty-only:

```text
Level + World::View
        |
        v
Render::Projector
        |
        v
Render::Scene
        |
        v
Render::Kitty
        |
        v
PNG assets
        |
        v
Host::Terminal
```

`Render::Scene` remains backend-neutral so later renderer experiments do not need to leak into simulation or game-state semantics.

`Render::Ascii` and fallback-glyph metadata remain as inactive legacy/reference code. The historically maintained dual ASCII/Kitty implementation is preserved in v0.3a.

Dialogue and battle status currently reuse the terminal status row rather than introducing a general UI-overlay system.

## Requirements

- Ruby 3.2 or newer
- Kitty, or another terminal environment currently detected as supporting the Kitty graphics protocol

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
W / ↑          move north
S / ↓          move south
A / ←          move west
D / →          move east
Enter / Space  interact / advance dialogue / attack
Esc            close dialogue / flee battle / quit exploration
Q              quit
```

Interaction is facing-based: stand beside an NPC or combatant, face toward it, and press Enter or Space.

During battle:

```text
Enter / Space  attack
Esc            flee
Q              quit
```

Party HP persists after fleeing or returning to Exploration. MP is persistent and validated but is not consumed by any gameplay system yet.

If Kitty graphics support is not detected, v0.3d exits instead of silently falling back to ASCII.

## Tests

```sh
bundle exec ruby -Itest -e \
  'Dir["test/*_test.rb"].sort.each { |file| require_relative file }'
```

## v0.3d scope

v0.3d closes the v0.3 architecture line by combining the earlier Kitty, Session/Party, interaction, and dialogue work with:

- minimal `BattleMode`;
- adjacent visible combat encounter entry;
- `Combatant(attack)` for the current battle prototype;
- explicit `Defeat` command for retiring zero-HP local enemies;
- persistent Session-owned party HP/MP;
- no `World::Health` on the controlled party runtime instance;
- battle damage that remains visible after returning to Exploration;
- status output exposing persistent HP/MP.

Deliberately deferred to v0.4 or later:

- final naming/replacement of `World`;
- broader persistent actor state beyond HP/MP;
- moving persistent attack/stats out of local runtime representation;
- a unified effect/resolution boundary spanning persistent and local state;
- inventory, equipment, skills, spells, and actual MP consumption;
- branching dialogue, quests, save serialization, and persistent NPC flags;
- general Scene/UI overlays;
- animation/interpolation and camera systems;
- enhanced physical-key event handling;
- Raylib integration.

Sunbird remains the evolving Ruby research implementation. A later Rust+Lua runtime experiment can use selected frozen Sunbird milestones as semantic references rather than replacing the Ruby project.
