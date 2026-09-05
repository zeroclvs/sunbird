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
            turn_commands
          )
        ) do |effects|
          session.apply_effects(effects)
        end

        return :quit if player_defeated?
        return :pop if enemy_defeated?

        :advanced
      end

      def level
        parent_mode.level
      end

      def area_view
        parent_mode.area_view
      end

      # Transitional v0.4 compatibility alias.
      alias world_view area_view

      def step_number
        parent_mode.step_number
      end

      def status_text
        player = player_actor.vitals

        "#{player_actor_key.to_s.capitalize} " \
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

      def player_actor_key
        session.party.leader
      end

      def player_actor
        session.actor(player_actor_key)
      end

      def player_id
        parent_mode.controlled_instance_id
      end

      def turn_commands
        player_damage = player_actor.stats.attack
        enemy = enemy_health

        commands = [
          Simulation::Commands::Attack.new(
            attacker_id: player_id,
            target_id: enemy_id,
            damage: player_damage
          )
        ]

        if player_damage >= enemy.current
          commands << Simulation::Commands::Defeat.new(
            instance_id: enemy_id
          )
        else
          commands << Simulation::Commands::Attack.new(
            attacker_id: enemy_id,
            target_id: player_id,
            damage: local_combatant(enemy_id).attack
          )
        end

        commands
      end

      def enemy_health
        area_view.component(enemy_id, :health)
      end

      def local_combatant(instance_id)
        area_view.component(instance_id, :combatant)
      end

      def player_defeated?
        player_actor.vitals.hp.zero?
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
        ref = area_view.component(instance_id, :entity_ref)
        (ref&.name || :unknown).to_s.capitalize
      end

      def validate_player!
        player_actor
      rescue KeyError
        raise ArgumentError,
          "party leader has no persistent actor state: " \
          "#{player_actor_key.inspect}"
      end

      def validate_enemy!
        unless enemy_health && local_combatant(enemy_id)
          raise ArgumentError,
            "battle enemy is not a local combatant: #{enemy_id.inspect}"
        end
      end
    end
  end
end
