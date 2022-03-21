require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

class Minitest::Test
  # memoize for performance
  def model
    @@model ||= Mitie::NER.new("#{models_path}/ner_model.dat")
  end

  def models_path
    ENV.fetch("MITIE_MODELS_PATH")
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
