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

      @server = Server.new(
        level: level,
        entities: entities
      )

      @mapper = Input::Mapper.new
      @handoff = Input::Handoff.new

      @projector = Render::Projector.new
      @renderer = Render::Ascii.new
      @terminal = Host::Terminal.new
      @terminal_input = Host::TerminalInput.new
    end

    def run
      @terminal.hide_cursor

      loop do
        draw

        physical_event = @terminal_input.read_event
        action = @mapper.map(physical_event)

        next unless action
        break if action.kind == :quit

        @handoff.push(action)
        @handoff.flip!

        snapshot = Input::Snapshot.from(
          @handoff.take_completed
        )

        @server.tick(input: snapshot)
      end
    ensure
      @terminal.show_cursor
      @terminal.clear
    end

    private

    def draw
      frame = @projector.project(
        level: @server.level,
        world: @server.world_view
      )

      @terminal.clear
      @terminal.write(@renderer.render(frame))
      @terminal.write(
        "\n\nWASD or arrow keys to move. Q to quit. " \
        "Tick #{@server.tick_number}\n"
      )
    end
  end
end
