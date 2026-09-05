# frozen_string_literal: true

module Sunbird
  module Mode
    class Battle
      attr_reader :parent_mode, :enemy_id

      def initialize(parent_mode:, enemy_id:)
        @parent_mode = parent_mode
        @enemy_id = enemy_id

        validate_player!
        validate_enemy!
      end

      def advance(input:)
        return :quit if input.pressed?(:quit)
        return :pop if input.pressed?(:cancel)
        return :quit if player_defeated?
        return :pop if enemy_defeated?
        return :waiting unless input.pressed?(:interact)

        simulation.step(
          commands: Simulation::Commands::Buffer.new(
            player_turn_commands
          )
        )

        return :pop if enemy_defeated?

        session.damage(
          player_member,
          combatant(enemy_id).attack
        )

        return :quit if player_defeated?

        :advanced
      end

      def level
        parent_mode.level
      end

      def world_view
        parent_mode.world_view
      end

      def step_number
        parent_mode.step_number
      end

      def status_text
        player = player_vitals

        "#{player_member.to_s.capitalize} " \
          "HP #{player.hp}/#{player.max_hp} " \
          "MP #{player.mp}/#{player.max_mp} | " \
          "#{display_name(enemy_id)} HP #{enemy_health_text} | " \
          "Enter/Space attack | Esc flee"
      end

      private

      def simulation
        parent_mode.simulation
      end

      def session
        parent_mode.session
      end

      def player_member
        session.party.leader
      end

      def player_id
        parent_mode.controlled_instance_id
      end

      def player_vitals
        session.vitals(player_member)
      end

      def player_turn_commands
        damage = combatant(player_id).attack
        enemy = enemy_health

        commands = [
          Simulation::Commands::Attack.new(
            attacker_id: player_id,
            target_id: enemy_id,
            damage: damage
          )
        ]

        if damage >= enemy.current
          commands << Simulation::Commands::Defeat.new(
            instance_id: enemy_id
          )
        end

        commands
      end

      def enemy_health
        world_view.component(enemy_id, :health)
      end

      def combatant(instance_id)
        world_view.component(instance_id, :combatant)
      end

      def player_defeated?
        player_vitals.hp.zero?
      end

      def enemy_defeated?
        enemy_health&.current&.zero?
      end

      def enemy_health_text
        value = enemy_health
        return "?/?" unless value

        "#{value.current}/#{value.max}"
      end

      def display_name(instance_id)
        ref = world_view.component(instance_id, :entity_ref)
        (ref&.name || :unknown).to_s.capitalize
      end

      def validate_player!
        unless combatant(player_id)
          raise ArgumentError,
            "party leader runtime instance is not a combatant: " \
            "#{player_id.inspect}"
        end

        player_vitals
      rescue KeyError
        raise ArgumentError,
          "party leader has no persistent vitals: " \
          "#{player_member.inspect}"
      end

      def validate_enemy!
        unless enemy_health && combatant(enemy_id)
          raise ArgumentError,
            "battle enemy is not a combatant: #{enemy_id.inspect}"
        end
      end
    end
  end
end
