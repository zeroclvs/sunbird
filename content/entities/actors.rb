# frozen_string_literal: true

module Sunbird
  class Entity
    module Definitions
      Actors = [
        Entity.new(
          name: :player,
          components: {
            health: World::Health.new(
              current: 10,
              max: 10
            ),
            renderable: World::Renderable.new(
              render_key: :player,
              glyph: "P",
              layer: 10
            ),
            collision: World::Collision.new(
              blocks_movement: true
            ),
            facing: World::Facing.new(
              direction: :south
            )
          }.freeze
        ),
        Entity.new(
          name: :goblin,
          components: {
            health: World::Health.new(
              current: 4,
              max: 4
            ),
            renderable: World::Renderable.new(
              render_key: :goblin,
              glyph: "G",
              layer: 10
            ),
            behavior: World::Behavior.new(
              kind: :chase
            ),
            collision: World::Collision.new(
              blocks_movement: true
            )
          }.freeze
        ),
        Entity.new(
          name: :villager,
          components: {
            renderable: World::Renderable.new(
              render_key: :villager,
              glyph: "V",
              layer: 10
            ),
            collision: World::Collision.new(
              blocks_movement: true
            ),
            interactable: World::Interactable.new(
              dialogue_key: :village_greeting
            )
          }.freeze
        )
      ].freeze
    end
  end
end
