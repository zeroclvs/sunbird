# frozen_string_literal: true

module Sunbird
  class World
    def initialize
      @next_instance_id = 0
      @component_tables = {}
    end

    def spawn(**components)
      instance_id = @next_instance_id
      @next_instance_id += 1

      components.each do |name, component|
        set_component(instance_id, name, component)
      end

      instance_id
    end

    def instance?(instance_id)
      instance_id.is_a?(Integer) &&
        instance_id >= 0 &&
        instance_id < @next_instance_id
    end

    def instance_ids
      (0...@next_instance_id).to_a.freeze
    end

    def component(instance_id, name)
      validate_instance!(instance_id)
      @component_tables[name]&.[](instance_id)
    end

    def set_component(instance_id, name, component)
      validate_instance!(instance_id)
      table_for(name)[instance_id] = component
    end

    def view
      View.new(self)
    end

    private

    def table_for(name)
      @component_tables[name] ||= ComponentTable.new
    end

    def validate_instance!(instance_id)
      return if instance?(instance_id)

      raise ArgumentError,
        "unknown instance_id: #{instance_id.inspect}"
    end
  end
end
