# frozen_string_literal: true

module Sunbird
  class Entity
    class Registry
      def initialize(entities)
        @entities = entities.to_h do |entity|
          [entity.name, entity]
        end.freeze
      end

      def fetch(name)
        @entities.fetch(name)
      end

      def include?(name)
        @entities.key?(name)
      end

      def names
        @entities.keys.freeze
      end
    end

    module Sources
    end
  end
end
