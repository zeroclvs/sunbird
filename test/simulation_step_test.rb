# frozen_string_literal: true

require_relative "test_helper"

class SimulationStepTest < Minitest::Test
  include SunbirdTestSupport

  def setup
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        )
      ],
      entry_spawn: :hero
    )

    @simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog
    )
    @hero_id = @simulation.instance_id_for_spawn(:hero)
  end

  def test_step_applies_explicit_commands
    commands = Sunbird::Simulation::Commands::Buffer.new(
      [
        Sunbird::Simulation::Commands::Move.new(
          instance_id: @hero_id,
          dx: 1,
          dy: 0
        )
      ]
    )

    result = @simulation.step(commands: commands)
    position = @simulation.area_view.component(
      @hero_id,
      :position
    )

    assert_equal [3, 2], [position.x, position.y]
    assert_equal 1, result
    assert_equal 1, @simulation.step_number
  end

  def test_step_yields_persistent_effects_without_changing_return_contract
    @simulation.bind_actor(
      actor_key: :hero,
      instance_id: @hero_id
    )

    attacker_id = @simulation.instance_id_for_spawn(:hero)

    # A second local instance adjacent to the hero.
    area = @simulation.instance_variable_get(:@area_state)
    enemy_id = area.spawn(
      position: Sunbird::AreaState::Position.new(
        x: 3,
        y: 2
      )
    )

    commands = Sunbird::Simulation::Commands::Buffer.new(
      [
        Sunbird::Simulation::Commands::Attack.new(
          attacker_id: enemy_id,
          target_id: attacker_id,
          damage: 1
        )
      ]
    )

    yielded = nil
    result = @simulation.step(commands: commands) do |effects|
      yielded = effects
    end

    assert_equal 1, result
    assert_equal 1, @simulation.step_number
    assert_equal 1, yielded.length
    assert_instance_of(
      Sunbird::Effects::DamageActor,
      yielded.first
    )
    assert_equal :hero, yielded.first.actor_key
  end

  def test_plan_does_not_advance_world
    commands = @simulation.plan(
      input: move_input(:move_east),
      controlled_id: @hero_id
    )
    position = @simulation.area_view.component(
      @hero_id,
      :position
    )

    assert_equal 1, commands.size
    assert_equal [2, 2], [position.x, position.y]
    assert_equal 0, @simulation.step_number
  end

  def test_world_view_has_no_mutation_api
    refute_respond_to @simulation.area_view, :set_component
  end
end
