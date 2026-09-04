# frozen_string_literal: true

module Sunbird
  class App
    ENTITY_PATH = File.expand_path(
      "../../content/entities/actors.rb",
      __dir__
    )

    LEVEL_PATH = File.expand_path(
      "../../content/levels/test_field.rb",
      __dir__
    )

    def initialize
      entities = Entity::Loader.load(ENTITY_PATH)
      level = Level::Loader.load(
        LEVEL_PATH,
        entities: entities
      )

      simulation = Simulation.new(
        level: level,
        entities: entities
      )

      @modes = ModeStack.new
      @modes.push(
        Mode::Exploration.new(simulation: simulation)
      )

      @mapper = Input::Mapper.new
      @handoff = Input::Handoff.new

      @projector = Render::Projector.new
      @renderer = Render::Ascii.new
      @host = Host::Terminal.new
    end

    def run
      @host.hide_cursor

      loop do
        draw

        physical_event = @host.read_event
        action = @mapper.map(physical_event)
        next unless action

        @handoff.push(action)
        @handoff.flip!

        snapshot = Input::Snapshot.from(
          @handoff.take_completed
        )

        result = @modes.current.advance(input: snapshot)
        break if result == :quit
      end
    ensure
      @host.show_cursor
      @host.clear
    end

    private

    def draw
      mode = @modes.current
      scene = @projector.project(
        level: mode.level,
        world: mode.world_view
      )

      @host.clear
      @host.write(@renderer.render(scene))
      @host.write(
        "\n\nWASD or arrow keys to move. Q to quit. "         "Step #{mode.step_number}\n"
      )
    end
  end
end
