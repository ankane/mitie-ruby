require_relative "test_helper"

class NERTrainerTest < Minitest::Test
  def test_beta_accessors
    trainer = Mitie::NERTrainer.new(feature_extractor_path)
    trainer.beta = 2.0
    assert_equal 2.0, trainer.beta
  end

  def test_beta_writer_raises_on_invalid_input
    trainer = Mitie::NERTrainer.new(feature_extractor_path)
    error = assert_raises(ArgumentError) do
      trainer.beta = -0.5
    end
    assert_equal "beta must be greater than or equal to zero", error.message
  end

  def test_num_threads_accessors
    trainer = Mitie::NERTrainer.new(feature_extractor_path)
    trainer.num_threads = 2
    assert_equal 2, trainer.num_threads
  end

  def test_train
    tokens = ["You", "can", "do", "machine", "learning", "in", "Ruby", "!"]
    instance = Mitie::NERTrainingInstance.new(tokens)
    instance.add_entity(3..4, "topic")
    instance.add_entity(6..6, "language")

    trainer = Mitie::NERTrainer.new(feature_extractor_path)
    trainer.add(instance)
    trainer.num_threads = 2
    model = silence_stdout { trainer.train }

    assert model.is_a?(Mitie::NER)

    entity = model.doc("Hello Ruby").entities.first
    assert_equal "Ruby", entity[:text]
    assert_equal "language", entity[:tag]
  end

  def test_empty_trainer
    trainer = Mitie::NERTrainer.new(feature_extractor_path)
    error = assert_raises(Mitie::Error) do
      trainer.train
    end
    assert_equal "You can't call train() on an empty trainer", error.message
  end

  def test_missing_file
    error = assert_raises(ArgumentError) do
      Mitie::NERTrainer.new("missing.dat")
    end
    assert_equal "File does not exist", error.message
  end
end
