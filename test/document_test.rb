require_relative "test_helper"

class DocumentTest < Minitest::Test
  def test_entities
    expected_entities = [
      {:text=>"Nat Friedman", :tag=>"PERSON", :score=>1.099661347535191, :offset=>0, :token_index=>0, :token_length=>2},
      {:text=>"GitHub", :tag=>"ORGANIZATION", :score=>0.3446416512516501, :offset=>27, :token_index=>6, :token_length=>1},
      {:text=>"San Francisco", :tag=>"LOCATION", :score=>1.428241888939011, :offset=>61, :token_index=>12, :token_length=>2}
    ]
    assert_equal expected_entities, doc.entities
  end

  def test_tokens
    expected_tokens = ["Nat", "Friedman", "is", "the", "CEO", "of", "GitHub", ",", "which", "is", "headquartered", "in", "San", "Francisco"]
    assert_equal expected_tokens, doc.tokens
  end

  def test_tokens_with_offset
    expected_tokens_with_offset = [["Nat", 0], ["Friedman", 4], ["is", 13], ["the", 16], ["CEO", 20], ["of", 24], ["GitHub", 27], [",", 33], ["which", 35], ["is", 41], ["headquartered", 44], ["in", 58], ["San", 61], ["Francisco", 65]]
    assert_equal expected_tokens_with_offset, doc.tokens_with_offset
  end

  def test_tokens_utf8
    assert_equal ["“", "hello", "”"], model.doc("“hello”").tokens
  end

  def test_tokens_with_offset_utf8
    # https://github.com/mit-nlp/MITIE/issues/211
    skip "Possible bug with MITIE"

    assert_equal [["“", 0], ["hello", 1], ["”", 6]], model.doc("“hello”").tokens_with_offset
  end

  def doc
    model.doc(text)
  end
end
