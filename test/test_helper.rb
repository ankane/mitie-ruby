require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"

class Minitest::Test
  def setup
    # autoload before GC.stress
    Mitie::FFI if stress?

    GC.stress = true if stress?
  end

  def teardown
    GC.stress = false if stress?
  end

  def stress?
    ENV["STRESS"]
  end

  def assert_elements_in_delta(expected, actual)
    assert_equal expected.size, actual.size
    expected.zip(actual) do |exp, act|
      assert_in_delta exp, act
    end
  end

  # memoize for performance
  def model
    @@model ||= Mitie::NER.new("#{models_path}/ner_model.dat")
  end

  def models_path
    ENV.fetch("MITIE_MODELS_PATH")
  end

  def feature_extractor_path
    "#{models_path}/total_word_feature_extractor.dat"
  end

  def text
    "Nat works at GitHub in San Francisco"
  end

  # capture_io does not suppress output
  def silence_stdout
    old_stdout = STDOUT.dup
    STDOUT.reopen(IO::NULL)
    STDOUT.sync = true
    yield
  ensure
    STDOUT.reopen(old_stdout)
    old_stdout.close
  end
end
