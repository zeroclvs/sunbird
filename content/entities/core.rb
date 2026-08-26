# frozen_string_literal: true

module Sunbird
  class Entity
    module Sources
      Core = [
        Entity.new(
          name: :player,
          components: {
            health: World::Health.new(
              current: 10,
              max: 10
            ),
            renderable: World::Renderable.new(
              glyph: "P",
              layer: 10
            ),
            collision: World::Collision.new(
              blocks_movement: true
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
              glyph: "G",
              layer: 10
            ),
            behavior: World::Behavior.new(
              kind: :wander
            ),
            collision: World::Collision.new(
              blocks_movement: true
            )
          }.freeze
        )
      ].freeze
    end
  end
end
