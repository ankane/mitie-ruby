require_relative "test_helper"

class NERTest < Minitest::Test
  def test_entities
    expected = [
      {:text=>"Nat Friedman", :tag=>"PERSON", :score=>1.099661347535191, :offset=>0, :token_index=>0, :token_length=>2},
      {:text=>"GitHub", :tag=>"ORGANIZATION", :score=>0.3446416512516501, :offset=>27, :token_index=>6, :token_length=>1},
      {:text=>"San Francisco", :tag=>"LOCATION", :score=>1.428241888939011, :offset=>61, :token_index=>12, :token_length=>2}
    ]
    assert_equal expected, model.entities(text)
  end

  def test_tokens
    expected = ["Nat", "Friedman", "is", "the", "CEO", "of", "GitHub", ",", "which", "is", "headquartered", "in", "San", "Francisco"]
    assert_equal expected, model.tokens(text)
  end

  def test_tokens_utf8
    assert_equal ["“", "hello", "”"], model.tokens("“hello”")
  end

  def test_tokens_with_offset
    expected = [["Nat", 0], ["Friedman", 4], ["is", 13], ["the", 16], ["CEO", 20], ["of", 24], ["GitHub", 27], [",", 33], ["which", 35], ["is", 41], ["headquartered", 44], ["in", 58], ["San", 61], ["Francisco", 65]]
    assert_equal expected, model.tokens_with_offset(text)
  end

  def test_tags
    assert_equal ["PERSON", "LOCATION", "ORGANIZATION", "MISC"], model.tags
  end

  def test_missing_file
    error = assert_raises(ArgumentError) do
      Mitie::NER.new("missing.dat")
    end
    assert_equal "File does not exist", error.message
  end
end
