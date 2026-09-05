# frozen_string_literal: true

require_relative "test_helper"

class DialogueCatalogTest < Minitest::Test
  def test_loads_authored_dialogue
    catalog = Sunbird::Dialogue::Loader.load(
      SunbirdTestPaths::DIALOGUE_PATH
    )

    assert_equal(
      [
        "The road north is dangerous.",
        "Keep your eyes on the old shrine."
      ],
      catalog.fetch(:village_greeting)
    )
  end

  def test_rejects_empty_dialogue
    error = assert_raises(ArgumentError) do
      Sunbird::Dialogue::Catalog.new({ empty: [] })
    end

    assert_match(/at least one line/, error.message)
  end
end
