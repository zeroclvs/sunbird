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
    end
  end
end
