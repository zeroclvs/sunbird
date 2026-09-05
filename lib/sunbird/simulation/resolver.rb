# frozen_string_literal: true

module Sunbird
  class Simulation
    class Resolver
      RETIRED_COMPONENTS = %i[
        behavior
        collision
        renderable
        combatant
        interactable
      ].freeze

      def initialize(movement: Movement.new)
        @movement = movement
      end

      def resolve(
        level:,
        commands:,
        area: nil,
        world: nil
      )
        area ||= world

        unless area
          raise ArgumentError,
            "Simulation::Resolver requires an area state"
        end

        effects = []

        commands.each do |command|
          effect =
            case command
            in Commands::Move
              resolve_move(area, level, command)
            in Commands::Attack
              resolve_attack(area, command)
            in Commands::Defeat
              resolve_defeat(area, command)
            else
              raise ArgumentError,
                "unsupported command: #{command.inspect}"
            end

          effects << effect if effect
        end

        effects.freeze
      end

      private

      def resolve_move(area, level, command)
        return unless area.instance?(command.instance_id)

        position = area.component(command.instance_id, :position)
        return unless position

        update_facing(area, command)

        next_x = position.x + command.dx
        next_y = position.y + command.dy

        return unless @movement.traversable?(
          level: level,
          world: area,
          x: next_x,
          y: next_y,
          except_id: command.instance_id
        )

        area.set_component(
          command.instance_id,
          :position,
          AreaState::Position.new(
            x: next_x,
            y: next_y
          )
        )

        nil
      end

      def update_facing(area, command)
        current = area.component(command.instance_id, :facing)
        return unless current

        direction = direction_for(command.dx, command.dy)
        return unless direction

        area.set_component(
          command.instance_id,
          :facing,
          AreaState::Facing.new(direction: direction)
        )
      end

      def direction_for(dx, dy)
        case [dx, dy]
        when [0, -1] then :north
        when [0, 1] then :south
        when [-1, 0] then :west
        when [1, 0] then :east
        end
      end

      def resolve_attack(area, command)
        return unless valid_attack?(area, command)

        health = area.component(command.target_id, :health)

        if health
          current = [
            health.current - command.damage,
            0
          ].max

          area.set_component(
            command.target_id,
            :health,
            AreaState::Health.new(
              current: current,
              max: health.max
            )
          )

          return nil
        end

        actor_ref = area.component(
          command.target_id,
          :actor_ref
        )
        return unless actor_ref

        Effects::DamageActor.new(
          actor_key: actor_ref.actor_key,
          amount: command.damage
        )
      end

      def valid_attack?(area, command)
        return false unless command.damage.positive?
        return false unless area.instance?(command.attacker_id)
        return false unless area.instance?(command.target_id)

        attacker = area.component(
          command.attacker_id,
          :position
        )
        target = area.component(
          command.target_id,
          :position
        )
        return false unless attacker && target

        (attacker.x - target.x).abs +
          (attacker.y - target.y).abs == 1
      end

      def resolve_defeat(area, command)
        return unless area.instance?(command.instance_id)

        health = area.component(command.instance_id, :health)
        return unless health&.current&.zero?

        RETIRED_COMPONENTS.each do |name|
          area.remove_component(
            command.instance_id,
            name
          )
        end

        nil
      end
    end
  end
end
