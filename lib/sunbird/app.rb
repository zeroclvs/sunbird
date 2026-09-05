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

    def initialize(env: ENV)
      entities = Entity::Loader.load(ENTITY_PATH)
      level = Level::Loader.load(
        LEVEL_PATH,
        entities: entities
      )
      @session = Session.new(
        party: Party.new(
          members: [:hero, :mage],
          leader: :hero
        )
      )
      simulation = Simulation.new(
        level: level,
        entities: entities
      )
      @modes = ModeStack.new
      @modes.push(
        Mode::Exploration.new(
          simulation: simulation,
          session: @session
        )
      )

      @mapper = Input::Mapper.new
      @handoff = Input::Handoff.new
      @projector = Render::Projector.new
      @host = Host::Terminal.new(env: env)
      @renderer = Render::Selector.build(
        capabilities: @host.capabilities
      )
    end

    def run
      @host.enter_application

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
      finish_renderer
      @host.leave_application
    end

    private

    def draw
      mode = @modes.current
      scene = @projector.project(
        level: mode.level,
        world: mode.world_view
      )
      synchronized = @renderer.synchronized_updates?
      @host.begin_synchronized_update if synchronized

      begin
        @host.clear if @renderer.clear_before_render?
        @host.write(@renderer.render(scene))
        @host.write_status(
          row: @renderer.status_row(scene),
          text: status_text(mode)
        )
      ensure
        @host.end_synchronized_update if synchronized
      end
    end

    def status_text(mode)
      "WASD or arrow keys to move. Q or Esc to quit. " \
        "Step #{mode.step_number}"
    end

    def finish_renderer
      return unless @renderer.respond_to?(:finish)

      output = @renderer.finish
      @host.write(output) unless output.empty?
    end
  end
end
