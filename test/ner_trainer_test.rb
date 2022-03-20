require "test_helper"

module Mitie
  class NERTrainerTest < Minitest::Test
    def test_beta_accessors
      trainer = Mitie::NERTrainer.new(feature_extractor)

      trainer.beta = 2.0

      assert_equal 2.0, trainer.beta
    end

    def test_beta_writer_raises_on_invalid_input
      trainer = Mitie::NERTrainer.new(feature_extractor)

      assert_raises(ArgumentError) { trainer.beta = -0.5 }
    end

    def test_num_threads_accessors
      trainer = Mitie::NERTrainer.new(feature_extractor)

      trainer.num_threads = 2

      assert_equal 2, trainer.num_threads
    end

    def test_train
      sample = Mitie::NERTrainingInstance.new(["My", "name", "is", "Hoots", "Owl", "and", "I", "work", "for", "Birdland", "."])
      sample.add_entity(3...5, "person")
      sample.add_entity(9...10, "org")

      sample2 = Mitie::NERTrainingInstance.new(["The", "other", "day", "at", "work", "I", "saw", "Oscar", "Grouch", "from", "Grouchland", "."])
      sample2.add_entity(7...9, "person")
      sample2.add_entity(10...11, "org")

      trainer = Mitie::NERTrainer.new(feature_extractor)
      trainer.add(sample)
      trainer.add(sample2)
      trainer.num_threads = Etc.nprocessors - 1

      ner = silence_stdout { trainer.train }

      assert ner.is_a?(Mitie::NER)
    end

    def test_train_raises_without_any_training_instances
      trainer = Mitie::NERTrainer.new(feature_extractor)

      assert_raises(StandardError) { trainer.train }
    end

    private

    def feature_extractor
      "#{models_path}/total_word_feature_extractor.dat"
    end
  end
end
