# frozen_string_literal: true

module Sunbird
  module Mode
    class Exploration
      DIRECTIONS = {
        north: [0, -1].freeze,
        south: [0, 1].freeze,
        west: [-1, 0].freeze,
        east: [1, 0].freeze
      }.freeze

      attr_reader :simulation, :session, :dialogues, :actor_bindings

      def initialize(simulation:, session:, dialogues:)
        @simulation = simulation
        @session = session
        @dialogues = dialogues
        @actor_bindings = bind_party_leader
      end

      def advance(input:)
        return :quit if input.pressed?(:quit)
        return :quit if input.pressed?(:cancel)

        if input.pressed?(:interact)
          return interaction_transition || :idle
        end

        commands = simulation.plan(
          input: input,
          controlled_id: controlled_instance_id
        )

        simulation.step(commands: commands) do |effects|
          session.apply_effects(effects)
        end

        :advanced
      end

      def level
        simulation.level
      end

      def area_view
        simulation.area_view
      end

      # Transitional v0.4 compatibility alias.
      alias world_view area_view

      def step_number
        simulation.step_number
      end

      def controlled_instance_id
        actor_bindings.fetch(session.party.leader)
      end

      def instance_id_for_party_member(member)
        actor_bindings[member]
      end

      def status_text
        leader = session.party.leader
        vitals = session.actor(leader).vitals

        "#{leader.to_s.capitalize} " \
          "HP #{vitals.hp}/#{vitals.max_hp} " \
          "MP #{vitals.mp}/#{vitals.max_mp} | " \
          "WASD/arrows move. Enter/Space interact. " \
          "Q or Esc quit. Step #{step_number}"
      end

      private

      def interaction_transition
        target_id = adjacent_target_id
        return unless target_id

        interactable = area_view.component(
          target_id,
          :interactable
        )
        return dialogue_transition(interactable) if interactable

        combatant = area_view.component(
          target_id,
          :combatant
        )
        return battle_transition(target_id) if combatant

        nil
      end

      def dialogue_transition(interactable)
        lines = dialogues.fetch(interactable.dialogue_key)

        Push.new(
          mode: Dialogue.new(
            parent_mode: self,
            lines: lines
          )
        )
      end

      def battle_transition(target_id)
        Push.new(
          mode: Battle.new(
            parent_mode: self,
            enemy_id: target_id
          )
        )
      end

      def adjacent_target_id
        origin = area_view.component(
          controlled_instance_id,
          :position
        )
        facing = area_view.component(
          controlled_instance_id,
          :facing
        )
        return unless origin && facing

        offset = DIRECTIONS[facing.direction]
        return unless offset

        target_x = origin.x + offset[0]
        target_y = origin.y + offset[1]

        area_view.instance_ids.find do |instance_id|
          next if instance_id == controlled_instance_id

          position = area_view.component(
            instance_id,
            :position
          )

          position &&
            position.x == target_x &&
            position.y == target_y
        end
      end

      def bind_party_leader
        entry_spawn = simulation.level.entry_spawn

        unless entry_spawn
          raise ArgumentError,
            "exploration level has no entry spawn"
        end

        actor_key = session.party.leader
        instance_id =
          simulation.instance_id_for_spawn(entry_spawn)

        simulation.bind_actor(
          actor_key: actor_key,
          instance_id: instance_id
        )

        ActorBindings.new(
          actor_key => instance_id
        )
      end
    end
  end
end
