# frozen_string_literal: true

require_relative "test_helper"

class RenderSelectorTest < Minitest::Test
  def test_auto_uses_ascii_without_graphics_capability
    renderer = Sunbird::Render::Selector.build(
      capabilities: Sunbird::Host::Capabilities.new(
        graphics_protocol: nil,
        keyboard_protocol: :legacy
      ),
      env: { "SUNBIRD_RENDERER" => "auto" }
    )

    assert_instance_of Sunbird::Render::Ascii, renderer
  end


  def test_auto_uses_kitty_when_capability_is_present
    renderer = Sunbird::Render::Selector.build(
      capabilities: Sunbird::Host::Capabilities.new(
        graphics_protocol: :kitty,
        keyboard_protocol: :legacy
      ),
      env: { "SUNBIRD_RENDERER" => "auto" }
    )

    assert_instance_of Sunbird::Render::Kitty, renderer
  end

  def test_ascii_override_wins_even_in_kitty
    renderer = Sunbird::Render::Selector.build(
      capabilities: Sunbird::Host::Capabilities.new(
        graphics_protocol: :kitty,
        keyboard_protocol: :legacy
      ),
      env: { "SUNBIRD_RENDERER" => "ascii" }
    )

    assert_instance_of Sunbird::Render::Ascii, renderer
  end

  def test_unknown_renderer_fails_fast
    error = assert_raises(ArgumentError) do
      Sunbird::Render::Selector.build(
        capabilities: Sunbird::Host::Capabilities.new(
          graphics_protocol: nil,
          keyboard_protocol: :legacy
        ),
        env: { "SUNBIRD_RENDERER" => "bogus" }
      )
    end

    assert_equal 'unknown renderer: "bogus"', error.message
  end
end
