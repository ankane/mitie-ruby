require_relative "test_helper"

class BinaryRelationTrainerTest < Minitest::Test
  def test_works
    trainer = Mitie::BinaryRelationTrainer.new(model)
    tokens = ["Shopify", "was", "founded", "in", "Ottawa"]
    trainer.add_positive_binary_relation(tokens, 0..0, 4..4)
    trainer.add_negative_binary_relation(tokens, 4...5, 0..0)
    assert_equal 1, trainer.num_positive_examples
    assert_equal 1, trainer.num_negative_examples
    detector = silence_stdout { trainer.train }
    assert_equal "", detector.name

    tempfile = Tempfile.new
    detector.save_to_disk(tempfile.path)
    assert File.exist?(tempfile.path)

    detector = Mitie::BinaryRelationDetector.new(tempfile.path)
    doc = model.doc("Shopify was founded in Ottawa")

    relations = detector.relations(doc)
    assert_equal 1, relations.size

    relation = relations.first
    assert_equal "Shopify", relation[:first]
    assert_equal "Ottawa", relation[:second]
    assert relation[:score]
  end

  def test_add_positive_binary_relation_invalid_range
    trainer = Mitie::BinaryRelationTrainer.new(model)
    tokens = ["Shopify", "was", "founded", "in", "Ottawa"]

    error = assert_raises(ArgumentError) do
      trainer.add_positive_binary_relation(tokens, 0...0, 4..4)
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      trainer.add_positive_binary_relation(tokens, 0..0, 4...4)
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      trainer.add_positive_binary_relation(tokens, 0..0, 4..5)
    end
    assert_equal "Invalid range", error.message
  end

  def test_add_negative_binary_relation_invalid_range
    trainer = Mitie::BinaryRelationTrainer.new(model)
    tokens = ["Shopify", "was", "founded", "in", "Ottawa"]

    error = assert_raises(ArgumentError) do
      trainer.add_negative_binary_relation(tokens, 0...0, 4..4)
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      trainer.add_negative_binary_relation(tokens, 0..0, 4...4)
    end
    assert_equal "Invalid range", error.message

    error = assert_raises(ArgumentError) do
      trainer.add_negative_binary_relation(tokens, 0..0, 4..5)
    end
    assert_equal "Invalid range", error.message
  end

  def test_add_positive_binary_relation_entities_overlap
    trainer = Mitie::BinaryRelationTrainer.new(model)
    tokens = ["Shopify", "was", "founded", "in", "Ottawa"]

    error = assert_raises(ArgumentError) do
      trainer.add_positive_binary_relation(tokens, 0..1, 1..2)
    end
    assert_equal "Entities overlap", error.message
  end

  def test_add_negative_binary_relation_entities_overlap
    trainer = Mitie::BinaryRelationTrainer.new(model)
    tokens = ["Shopify", "was", "founded", "in", "Ottawa"]

    error = assert_raises(ArgumentError) do
      trainer.add_negative_binary_relation(tokens, 0..1, 1..2)
    end
    assert_equal "Entities overlap", error.message
  end

  def test_empty_trainer
    trainer = Mitie::BinaryRelationTrainer.new(model)
    error = assert_raises(Mitie::Error) do
      trainer.train
    end
    assert_equal "You can't call train() on an empty trainer", error.message
  end
end
