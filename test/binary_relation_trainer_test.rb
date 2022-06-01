require_relative "test_helper"

class BinaryRelationTrainerTest < Minitest::Test
  def test_works
    trainer = Mitie::BinaryRelationTrainer.new(model)
    tokens = ["Shopify", "was", "founded", "in", "Ottawa"]
    trainer.add_positive_binary_relation(tokens, 0..0, 4..4)
    trainer.add_negative_binary_relation(tokens, 4..4, 0..0)
    assert_equal 1, trainer.num_positive_examples
    assert_equal 1, trainer.num_negative_examples
    detector = silence_stdout { trainer.train }
    assert_equal "unnamed", detector.name

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
end
