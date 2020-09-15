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
    "Nat Friedman is the CEO of GitHub, which is headquartered in San Francisco"
  end
end
