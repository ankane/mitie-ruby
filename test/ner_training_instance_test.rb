require_relative "test_helper"

class NERTrainingInstanceTest < Minitest::Test
  def test_add_entity_raises_on_invalid_input
    tokens = ["I", "raise", "errors", "."]
    instance = Mitie::NERTrainingInstance.new(tokens)
    instance.add_entity(2..2, "noun")

    error = assert_raises(ArgumentError) do
      instance.add_entity(1...1, "nope")
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      instance.add_entity(1...9, "nope")
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      instance.add_entity(-1...2, "nope")
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      instance.add_entity(2..2, "nope")
    end
    assert_equal "Range overlaps existing entity", error.message
  end

  def test_num_entities
    tokens = ["You", "can", "do", "machine", "learning", "in", "Ruby", "!"]
    instance = Mitie::NERTrainingInstance.new(tokens)

    assert_equal 0, instance.num_entities

    instance.add_entity(3..4, "topic")
    instance.add_entity(6..6, "language")

    assert_equal 2, instance.num_entities
  end

  def test_num_tokens
    tokens = ["I", "have", "five", "tokens", "."]
    instance = Mitie::NERTrainingInstance.new(tokens)
    assert_equal 5, instance.num_tokens
  end

  def test_overlaps_any_entity
    tokens = ["You", "can", "do", "machine", "learning", "in", "Ruby", "!"]
    instance = Mitie::NERTrainingInstance.new(tokens)
    instance.add_entity(3..4, "topic")
    instance.add_entity(6..6, "language")

    refute instance.overlaps_any_entity?(1..2)
    assert instance.overlaps_any_entity?(2..3)
    refute instance.overlaps_any_entity?(5..5)
  end

  def test_overlaps_any_entity_raises_errors
    tokens = ["I", "raise", "errors", "."]
    instance = Mitie::NERTrainingInstance.new(tokens)
    instance.add_entity(2..2, "noun")

    error = assert_raises(ArgumentError) do
      instance.overlaps_any_entity?(1...1)
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      instance.overlaps_any_entity?(9..12)
    end
    assert_equal "Invalid range", error.message
  end
end
