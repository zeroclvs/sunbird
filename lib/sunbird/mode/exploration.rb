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

      attr_reader :simulation, :session, :dialogues

      def initialize(simulation:, session:, dialogues:)
        @simulation = simulation
        @session = session
        @dialogues = dialogues
        @party_instances = bind_party_leader.freeze
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
        simulation.step(commands: commands)
        :advanced
      end

      def level
        simulation.level
      end

      def world_view
        simulation.world_view
      end

      def step_number
        simulation.step_number
      end

      def controlled_instance_id
        @party_instances.fetch(session.party.leader)
      end

      def instance_id_for_party_member(member)
        @party_instances[member.to_sym]
      end

      def status_text
        "WASD/arrows move. Enter/Space interact. Q or Esc quit. " \
          "Step #{step_number}"
      end

      private

      def interaction_transition
        target_id = interaction_target_id
        return unless target_id

        interactable = world_view.component(
          target_id,
          :interactable
        )
        lines = dialogues.fetch(interactable.dialogue_key)

        Push.new(
          mode: Dialogue.new(
            parent_mode: self,
            lines: lines
          )
        )
      end

      def interaction_target_id
        origin = world_view.component(
          controlled_instance_id,
          :position
        )
        facing = world_view.component(
          controlled_instance_id,
          :facing
        )
        return unless origin && facing

        offset = DIRECTIONS[facing.direction]
        return unless offset

        target_x = origin.x + offset[0]
        target_y = origin.y + offset[1]

        world_view.instance_ids.find do |instance_id|
          next if instance_id == controlled_instance_id

          position = world_view.component(
            instance_id,
            :position
          )
          interactable = world_view.component(
            instance_id,
            :interactable
          )

          position &&
            interactable &&
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

        {
          session.party.leader => simulation.instance_id_for_spawn(entry_spawn)
        }
      end
    end
  end
end
