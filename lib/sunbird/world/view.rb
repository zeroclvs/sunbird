# frozen_string_literal: true

module Sunbird
  class World
    class View
      def initialize(world)
        @world = world
      end

      def instance?(instance_id)
        @world.instance?(instance_id)
      end

      def instance_ids
        @world.instance_ids
      end

      def component(instance_id, name)
        @world.component(instance_id, name)
      end

      def relation_targets(kind:, source_id:)
        @world.relation_targets(
          kind: kind,
          source_id: source_id
        )
      end
    end
  end
end
