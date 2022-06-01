require_relative "test_helper"

class TextCategorizerTest < Minitest::Test
  def test_works
    trainer = Mitie::TextCategorizerTrainer.new(feature_extractor_path)
    trainer.add(["This", "is", "super", "cool"], "positive")
    trainer.add(["I", "am", "not", "a", "fan"], "negative")
    model = silence_stdout { trainer.train }

    tempfile = Tempfile.new
    model.save_to_disk(tempfile.path)
    assert File.exist?(tempfile.path)

    model = Mitie::TextCategorizer.new(tempfile.path)
    result = model.categorize(["What", "a", "super", "nice", "day"])
    assert_equal "positive", result[:tag]
  end

  def test_empty_trainer
    trainer = Mitie::TextCategorizerTrainer.new(feature_extractor_path)
    error = assert_raises(Mitie::Error) do
      trainer.train
    end
    assert_equal "You can't call train() on an empty trainer", error.message
  end
end
