# frozen_string_literal: true

module Sunbird
  class Server
    class TickBuilder
      WANDER_DIRECTIONS = [
        [0, -1].freeze,
        [1, 0].freeze,
        [0, 1].freeze,
        [-1, 0].freeze
      ].freeze

      def initialize(activation:, pathfinder: Pathfinder.new)
        @activation = activation
        @pathfinder = pathfinder
      end

      def build(input:, level:, world:, player_instance:)
        active_instances = @activation.active_instances(
          level: level,
          world: world
        )

        commands = []
        active_instances.each do |instance_id|
          command =
            if instance_id == player_instance
              player_move(
                input,
                player_instance
              )
            else
              behavior_command(
                level,
                world,
                instance_id
              )
            end

          commands << command if command
        end

        CommandBuffer.new(commands)
      end

      private

      def player_move(input, player_instance)
        dx = 0
        dy = 0

        dx -= 1 if input.pressed?(:move_west)
        dx += 1 if input.pressed?(:move_east)
        dy -= 1 if input.pressed?(:move_north)
        dy += 1 if input.pressed?(:move_south)

        return if dx.zero? && dy.zero?

        Commands::Move.new(
          instance: player_instance,
          dx: dx,
          dy: dy
        )
      end

      def behavior_command(level, world, instance_id)
        behavior = world.component(
          instance_id,
          :behavior
        )

        return unless behavior

        case behavior.kind
        when :idle
          nil
        when :wander
          wander_move(instance_id)
        when :chase
          chase_move(level, world, instance_id)
        else
          raise ArgumentError,
            "unknown behavior: #{behavior.kind.inspect}"
        end
      end

      def wander_move(instance_id)
        dx, dy = WANDER_DIRECTIONS.sample

        Commands::Move.new(
          instance: instance_id,
          dx: dx,
          dy: dy
        )
      end

      def chase_move(level, world, instance_id)
        target_id = world.relation_targets(
          kind: :targets,
          source_id: instance_id
        ).first
        return unless target_id

        if adjacent?(world, instance_id, target_id)
          return Commands::Attack.new(
            attacker: instance_id,
            target: target_id,
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
          instance: instance_id,
          dx: dx,
          dy: dy
        )
      end

      def adjacent?(world, source_id, target_id)
        source = world.component(source_id, :position)
        target = world.component(target_id, :position)
        return false unless source && target

        distance =
          (source.x - target.x).abs +
          (source.y - target.y).abs

        distance == 1
      end
    end
  end
end
