# frozen_string_literal: true

require_relative "test_helper"

class ExplorationModeTest < Minitest::Test
  include SunbirdTestSupport

  def setup
    level = level_with(
      spawns: [
        Sunbird::Level::Spawn.new(
          key: :hero,
          entity: :player,
          x: 2,
          y: 2
        ),
        Sunbird::Level::Spawn.new(
          key: :villager,
          entity: :villager,
          x: 3,
          y: 2
        )
      ],
      entry_spawn: :hero
    )
    simulation = Sunbird::Simulation.new(
      level: level,
      entities: actor_catalog
    )
    @session = test_session
    @mode = Sunbird::Mode::Exploration.new(
      simulation: simulation,
      session: @session,
      dialogues: dialogue_catalog
    )
  end

  def test_exploration_mode_decides_when_simulation_advances
    result = @mode.advance(input: move_input(:move_south))

    assert_equal :advanced, result
    assert_equal 1, @mode.step_number
  end

  def test_party_leader_is_bound_to_level_entry_spawn
    hero_id = @mode.controlled_instance_id
    position = @mode.world_view.component(hero_id, :position)

    assert_equal hero_id, @mode.instance_id_for_party_member(:hero)
    assert_nil @mode.instance_id_for_party_member(:mage)
    assert_equal [2, 2], [position.x, position.y]
  end

  def test_party_leader_world_instance_does_not_own_health
    hero_id = @mode.controlled_instance_id

    assert_nil @mode.world_view.component(hero_id, :health)
    assert_equal 10, @session.vitals(:hero).hp
  end

  def test_status_uses_persistent_session_vitals
    @session.damage(:hero, 3)
    @session.spend_mp(:hero, 1)

    assert_match "Hero HP 7/10 MP 3/4", @mode.status_text
  end

  def test_blocked_move_still_changes_facing
    @mode.advance(input: move_input(:move_east))

    hero_id = @mode.controlled_instance_id
    position = @mode.world_view.component(hero_id, :position)
    facing = @mode.world_view.component(hero_id, :facing)

    assert_equal [2, 2], [position.x, position.y]
    assert_equal :east, facing.direction
    assert_equal 1, @mode.step_number
  end

  def test_interaction_pushes_dialogue_without_advancing_simulation
    @mode.advance(input: move_input(:move_east))
    before = @mode.step_number

    result = @mode.advance(input: action_input(:interact))

    assert_instance_of Sunbird::Mode::Push, result
    assert_instance_of Sunbird::Mode::Dialogue, result.mode
    assert_equal "First line.", result.mode.current_line
    assert_equal before, @mode.step_number
  end

  def test_interact_without_target_does_not_advance
    result = @mode.advance(input: action_input(:interact))

    assert_equal :idle, result
    assert_equal 0, @mode.step_number
  end

  def test_quit_and_cancel_do_not_advance_simulation
    assert_equal :quit, @mode.advance(input: action_input(:quit))
    assert_equal 0, @mode.step_number

    assert_equal :quit, @mode.advance(input: action_input(:cancel))
    assert_equal 0, @mode.step_number
  end
end
