# frozen_string_literal: true

module Sunbird
  class Server
    class Activation
      def active_instances(level:, world:)
        world.instance_ids
      end
    end
  end
end
