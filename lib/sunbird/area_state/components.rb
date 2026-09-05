# frozen_string_literal: true

module Sunbird
  class AreaState
    EntityRef = Data.define(:name)
    ActorRef = Data.define(:actor_key)

    Position = Data.define(:x, :y)
    Health = Data.define(:current, :max)
    Renderable = Data.define(
      :render_key,
      :glyph,
      :layer
    )
    Behavior = Data.define(:kind)
    Collision = Data.define(:blocks_movement)
    Facing = Data.define(:direction)
    Interactable = Data.define(:dialogue_key)
    Combatant = Data.define(:attack)
  end
end
