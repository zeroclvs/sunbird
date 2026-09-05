# Sunbird v0.3d Architecture

Sunbird v0.3d is the final planned release of the v0.3 architecture line. It combines Kitty presentation, a level-local simulation, persistent Session/Party identity, interaction/dialogue modes, a minimal Battle mode, and the first explicit split between persistent party vitals and local runtime actor state.

The Ruby implementation is a research/prototype engine. Its purpose is to make ownership, lifetime, and gameplay boundaries concrete enough to evaluate and later re-express—not to preserve every current class name indefinitely.

## Vocabulary

| Term | Meaning |
| --- | --- |
| `App` | executable shell connecting input, modes, rendering, and host I/O |
| `Session` | persistent state that survives local Simulation/World lifetimes |
| `Party` | ordered roster of stable party-member identities plus leader |
| `Session::Vitals` | persistent HP/MP values for one party member |
| `ModeStack` | owns the active gameplay/application context |
| `Exploration` | binds party control, advances local simulation, and handles interaction |
| `Dialogue` | consumes dialogue input while leaving Exploration simulation suspended |
| `Battle` | consumes combat input and coordinates local enemy state with persistent party vitals |
| `Simulation` | owns one loaded Level/World runtime and authoritative World command application |
| `Level` | immutable authored description of one playable area |
| `Terrain` | authored spatial/passability data inside a Level |
| `Entity` | reusable authored component recipe |
| `Spawn` | authored instruction to instantiate an Entity |
| `InstanceId` | integer identity of one local runtime instance |
| `World` | mutable level-local components and runtime relations |
| `Health` | level-local HP component, currently used by enemies |
| `Combatant` | local combat component containing attack power in v0.3d |
| `Facing` | local cardinal interaction direction |
| `Interactable` | local component referencing authored dialogue |
| `Planner` | optional read-only command producer used by Exploration simulation |
| `Resolver` | authoritative validator/applier for World commands |
| `Scene` | backend-neutral presentation snapshot from Level + World::View |
| `Host` | terminal/platform I/O boundary |

## Lifetime domains

The most important v0.3d distinction is lifetime.

```text
persistent
────────────────────────────────────
Session
├── Party
└── Vitals
    ├── :hero
    └── :mage

authored / immutable
────────────────────────────────────
Level
├── Terrain
├── Spawns
└── static Relations

level-local / mutable
────────────────────────────────────
World
├── runtime instances
├── positions
├── facing
├── collision
├── behavior
├── local Health
├── Combatant
└── runtime Relations
```

`Session` never stores World `InstanceId`s. Stable party identity such as `:hero` is distinct from the runtime instance used to represent that actor inside one loaded Level.

## Persistent party vitals

v0.3d makes party HP/MP authoritative in Session:

```text
:hero
  ↓
Session::Vitals
  hp
  max_hp
  mp
  max_mp
```

The player Entity recipe no longer supplies `World::Health`.

Therefore `Session#vitals(:hero)` is the one authoritative player HP/MP value, while `World#component(player_id, :health)` is intentionally absent.

Session validates that every party member has vitals, clamps healing/damage, prevents invalid MP spending, and stores replacement immutable Vitals values.

This is deliberately **not yet a complete persistent actor model**. Player attack remains in the local `Combatant` component. That asymmetry is one of the explicit inputs to the v0.4 redesign.

## Level and World

`Level` is immutable authored area data. Instantiating a Level creates local World instances and resolves authored spawn-key relations into runtime `InstanceId` relations.

`World` remains level-local. Enemy HP, movement, behavior, collision, pathfinding context, and runtime relations belong there.

The name `World` is now recognized as potentially confusing for a JRPG that may also have an overworld/world map. v0.3d intentionally leaves the name unchanged; v0.4 will reconsider it.

## Simulation

The core API remains:

```text
Simulation#plan(input:, controlled_id:)
Simulation#step(commands:)
```

`plan` asks Planner to derive command intent from read-only state. It does not mutate World.

`step` gives explicit commands to Resolver and increments `step_number`.

A **step is a state transition, not a clock tick**.

Modes choose when a step occurs. Dialogue does not step the simulation. Exploration normally does. Battle calls `Simulation#step` when a player combat turn applies World commands.

## Commands and Resolver

v0.3d World commands are:

```text
Move(instance_id, dx, dy)
Attack(attacker_id, target_id, damage)
Defeat(instance_id)
```

The rule remains:

```text
command producer = proposed World intent
Resolver         = authoritative World mutation
```

`Move` validates traversability and updates Facing even if movement is blocked.

`Attack` validates local attacker/target instances and adjacency, then reduces target `World::Health`.

`Defeat` only retires an instance whose World Health is already zero. It removes behavior, collision, rendering, combat, and interactability while leaving identity, position, and zero Health available as local historical state.

## Modes and transitions

`App` owns actual ModeStack mutation. Modes return transition intent.

```text
Exploration
   |
   +-- interact with Interactable
   |        ↓
   |   Push(Dialogue)
   |
   `-- interact with adjacent Combatant
            ↓
        Push(Battle)
```

Dialogue consumes Enter/Space, Escape, and Quit without advancing Simulation.

Battle consumes Enter/Space for turns, Escape to flee, and Quit to exit. Both Dialogue and Battle expose the suspended Exploration Level/World view so the same underlying Scene remains visible.

## Battle ownership

Battle is intentionally small.

The player's attack is expressed as a normal World `Attack` command and optional `Defeat` command:

```text
Battle
  ↓
Simulation#step
  ↓
Resolver
  ↓
enemy World::Health
```

Enemy retaliation currently uses the persistent lifetime domain:

```text
enemy Combatant.attack
        ↓
Battle
        ↓
Session#damage(:hero, amount)
        ↓
persistent party HP
```

v0.3d therefore has two mutation authorities for two different kinds of state:

```text
Resolver → local World state
Session  → persistent party vitals
```

There is no duplicated party HP between them.

However, Battle itself currently knows how to route effects to both domains. A future unified gameplay-effect boundary is deliberately deferred to v0.4.

## Interaction and dialogue

Facing uses four cardinal directions: `:north`, `:south`, `:east`, and `:west`.

Resolver updates Facing before movement legality is resolved, so pressing toward a blocking NPC or enemy still turns the controlled actor toward it.

Exploration checks the adjacent cell in the Facing direction. Interaction priority is:

```text
Interactable → Dialogue
Combatant    → Battle
otherwise    → no interaction transition
```

Dialogue content remains a small authored mapping from `dialogue_key` to ordered lines. No branching, conditions, scripting, or persistent dialogue flags exist yet.

## Presentation

Projection remains backend-neutral:

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
Host::Terminal
```

The current Scene contains terrain and runtime instances with semantic render keys, positions, layers, fallback glyphs, and stable instance IDs.

Dialogue and Battle UI text still uses the terminal status row. There is no generic UI-overlay scene model yet.

`Render::Ascii` remains inactive legacy/reference code. v0.3d requires Kitty graphics support at runtime.

## Host and input

`Host::Terminal` owns alternate-screen lifecycle, synchronized output, and persistent raw terminal input mode.

The terminal decoder supports WASD, arrows, Enter, Space, Escape, Q, and Ctrl-C. The mapper converts these into movement, interact, cancel, and quit actions, and Modes interpret them contextually.

Enhanced Kitty keyboard press/repeat/release reporting remains deliberately out of scope.

## Content

Temporary Ruby-authored content remains under:

```text
content/entities/
content/levels/
content/dialogue/
```

Loaders reuse `Content::RubySource`. This is prototype scaffolding, not a commitment to Ruby source as the long-term content/persistence format.

## v0.3d architectural boundary

The v0.3 line now proves:

- authored Level versus mutable local runtime state;
- stable party identity versus runtime InstanceId;
- persistent Session state versus local World state;
- mode-owned advancement policy;
- Exploration, Dialogue, and Battle contexts;
- explicit World command/Resolver authority;
- persistent party HP/MP without a mirrored World Health component;
- visible encounter entry, flee, victory, and local enemy retirement;
- backend-neutral Scene projection with Kitty presentation.

Known tensions intentionally left for v0.4:

- `World` naming versus a future overworld/world-map concept;
- Session as a growing persistent-state root;
- lack of a general persistent `ActorState`;
- player attack still stored in local `Combatant`;
- Battle directly coordinating Session and World mutation domains;
- no unified effect/resolution layer spanning both lifetimes;
- no explicit reusable binding object from stable actor identity to local runtime instance.

See [`v0.4-state-model-proposal.md`](v0.4-state-model-proposal.md).

## Deferred gameplay and presentation systems

Not part of v0.3d:

- inventory/equipment;
- spells, skills, and actual MP use;
- party-wide battle participation;
- battle menus or target selection;
- save serialization;
- branching dialogue and quests;
- persistent NPC/world-change state;
- general UI overlay system;
- camera/viewport;
- interpolation/animation;
- Raylib integration;
- fixed-step realtime scheduling.
