# frozen_string_literal: true

module Sunbird
  class Simulation
    class Resolver
      def initialize(movement: Movement.new)
        @movement = movement
      end

      def resolve(world:, level:, commands:)
        commands.each do |command|
          case command
          in Commands::Move
            resolve_move(world, level, command)
          in Commands::Attack
            resolve_attack(world, command)
          else
            raise ArgumentError,
              "unsupported command: #{command.inspect}"
          end
        end
      end

      private

      def resolve_move(world, level, command)
        return unless world.instance?(command.instance_id)

        position = world.component(command.instance_id, :position)
        return unless position

        next_x = position.x + command.dx
        next_y = position.y + command.dy

        return unless @movement.traversable?(
          level: level,
          world: world,
          x: next_x,
          y: next_y,
          except_id: command.instance_id
        )

        world.set_component(
          command.instance_id,
          :position,
          World::Position.new(
            x: next_x,
            y: next_y
          )
        )
      end

      def resolve_attack(world, command)
        return unless valid_attack?(world, command)

        health = world.component(command.target_id, :health)
        return unless health

        current = [health.current - command.damage, 0].max

        world.set_component(
          command.target_id,
          :health,
          World::Health.new(
            current: current,
            max: health.max
          )
        )
      end

      def valid_attack?(world, command)
        return false unless command.damage.positive?
        return false unless world.instance?(command.attacker_id)
        return false unless world.instance?(command.target_id)

        attacker = world.component(command.attacker_id, :position)
        target = world.component(command.target_id, :position)
        return false unless attacker && target

        (attacker.x - target.x).abs +
          (attacker.y - target.y).abs == 1
      end
    end
  end
end
