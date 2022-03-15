require "test_helper"

module Mitie
  class NERTrainingInstanceTest < Minitest::Test
    def test_add_entity_raises_on_invalid_input
      sample = Mitie::NERTrainingInstance.new(
        ["I", "raise", "errors", "."]
      )
      sample.add_entity((2..2), "noun")

      assert_raises(ArgumentError) { sample.add_entity(1...1, "nope") }
      assert_raises(ArgumentError) { sample.add_entity(1...9, "nope") }
      assert_raises(ArgumentError) { sample.add_entity(-1...2, "nope") }
      assert_raises(ArgumentError) { sample.add_entity(2..2, "nope") }
    end

    def test_num_entities
      sample = Mitie::NERTrainingInstance.new(
        ["My", "name", "is", "Hoots", "Owl", "and", "I", "work", "for", "Birdland", "."]
      )

      assert_equal 0, sample.num_entities

      sample.add_entity(3...5, "person")
      sample.add_entity(9...10, "org")

      assert_equal 2, sample.num_entities
    end

    def test_num_tokens
      sample = Mitie::NERTrainingInstance.new(
        ["I", "have", "five", "tokens", "."]
      )

      assert_equal 5, sample.num_tokens
    end

    def test_overlaps_any_entity
      sample = Mitie::NERTrainingInstance.new(
        ["I", "am", "become", "Death", ",", "destroyer", "of", "worlds", "."]
      )
      sample.add_entity(0..0, "person")
      sample.add_entity(3..3, "phenomenon")

      assert sample.overlaps_any_entity?(1..3)
      refute sample.overlaps_any_entity?(5..8)
    end

    def test_overlaps_any_entity_raises_errors
      sample = Mitie::NERTrainingInstance.new(
        ["I", "raise", "errors", "."]
      )
      sample.add_entity(2..2, "noun")

      assert_raises(ArgumentError) { sample.overlaps_any_entity?(1...1) }
      assert_raises(ArgumentError) { sample.overlaps_any_entity?(9..12) }
    end
  end
end
