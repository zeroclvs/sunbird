# frozen_string_literal: true

module Sunbird
  class Server
    class Planner
      WANDER_DIRECTIONS = [
        [0, -1].freeze,
        [1, 0].freeze,
        [0, 1].freeze,
        [-1, 0].freeze
      ].freeze

      def initialize(relevance:, pathfinder: Pathfinder.new)
        @relevance = relevance
        @pathfinder = pathfinder
      end

      def build(input:, level:, world:, controlled_id:)
        relevant_instances = @relevance.relevant_instances(
          level: level,
          world: world
        )

        commands = []

        relevant_instances.each do |instance_id|
          command =
            if instance_id == controlled_id
              controlled_move(input, controlled_id)
            else
              behavior_command(level, world, instance_id)
            end

          commands << command if command
        end

        Commands::Buffer.new(commands)
      end

      private

      def controlled_move(input, instance_id)
        dx = 0
        dy = 0

        dx -= 1 if input.pressed?(:move_west)
        dx += 1 if input.pressed?(:move_east)
        dy -= 1 if input.pressed?(:move_north)
        dy += 1 if input.pressed?(:move_south)

        return if dx.zero? && dy.zero?

        Commands::Move.new(
          instance_id: instance_id,
          dx: dx,
          dy: dy
        )
      end

      def behavior_command(level, world, instance_id)
        behavior = world.component(instance_id, :behavior)
        return unless behavior

        case behavior.kind
        when :idle
          nil
        when :wander
          wander_move(instance_id)
        when :chase
          chase(level, world, instance_id)
        else
          raise ArgumentError,
            "unknown behavior: #{behavior.kind.inspect}"
        end
      end

      def wander_move(instance_id)
        dx, dy = WANDER_DIRECTIONS.sample

        Commands::Move.new(
          instance_id: instance_id,
          dx: dx,
          dy: dy
        )
      end

      def chase(level, world, instance_id)
        target_id = world.relation_targets(
          kind: :targets,
          source_id: instance_id
        ).first
        return unless target_id

        if adjacent?(world, instance_id, target_id)
          return Commands::Attack.new(
            attacker_id: instance_id,
            target_id: target_id,
            damage: 1
          )
        end

        step = @pathfinder.next_step(
          level: level,
          world: world,
          source_id: instance_id,
          target_id: target_id
        )
        return unless step

        dx, dy = step

        Commands::Move.new(
          instance_id: instance_id,
          dx: dx,
          dy: dy
        )
      end

      def adjacent?(world, source_id, target_id)
        source = world.component(source_id, :position)
        target = world.component(target_id, :position)
        return false unless source && target

        (source.x - target.x).abs +
          (source.y - target.y).abs == 1
      end
    end
  end
end
