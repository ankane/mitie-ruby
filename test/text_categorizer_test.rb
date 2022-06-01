require_relative "test_helper"

class TextCategorizerTest < Minitest::Test
  def test_works
    trainer = Mitie::TextCategorizerTrainer.new(feature_extractor)
    trainer.add_labeled_text(["This", "is", "super", "cool"], "positive")
    trainer.add_labeled_text(["I", "am", "not", "a", "fan"], "negative")
    model = silence_stdout { trainer.train }

    tempfile = Tempfile.new
    model.save_to_disk(tempfile.path)
    assert File.exist?(tempfile.path)

    model = Mitie::TextCategorizer.new(tempfile.path)
    result = model.categorize(["What", "a", "super", "nice", "day"])
    assert_equal "positive", result[:tag]
  end
end
