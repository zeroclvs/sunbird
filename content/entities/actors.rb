# frozen_string_literal: true

module Sunbird
  class Entity
    module Definitions
      Actors = [
        Entity.new(
          name: :player,
          components: {
            renderable: AreaState::Renderable.new(
              render_key: :player,
              glyph: "P",
              layer: 10
            ),
            collision: AreaState::Collision.new(
              blocks_movement: true
            ),
            facing: AreaState::Facing.new(
              direction: :south
            )
          }.freeze
        ),
        Entity.new(
          name: :goblin,
          components: {
            health: AreaState::Health.new(
              current: 4,
              max: 4
            ),
            renderable: AreaState::Renderable.new(
              render_key: :goblin,
              glyph: "G",
              layer: 10
            ),
            behavior: AreaState::Behavior.new(
              kind: :chase
            ),
            collision: AreaState::Collision.new(
              blocks_movement: true
            ),
            combatant: AreaState::Combatant.new(
              attack: 1
            )
          }.freeze
        ),
        Entity.new(
          name: :villager,
          components: {
            renderable: AreaState::Renderable.new(
              render_key: :villager,
              glyph: "V",
              layer: 10
            ),
            collision: AreaState::Collision.new(
              blocks_movement: true
            ),
            interactable: AreaState::Interactable.new(
              dialogue_key: :village_greeting
            )
          }.freeze
        )
      ].freeze
    end
  end
end
