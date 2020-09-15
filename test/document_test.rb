require_relative "test_helper"

class DocumentTest < Minitest::Test
  def test_entities
    expected = [
      {:text=>"Nat Friedman", :tag=>"PERSON", :score=>1.099661347535191, :offset=>0, :token_index=>0, :token_length=>2},
      {:text=>"GitHub", :tag=>"ORGANIZATION", :score=>0.3446416512516501, :offset=>27, :token_index=>6, :token_length=>1},
      {:text=>"San Francisco", :tag=>"LOCATION", :score=>1.428241888939011, :offset=>61, :token_index=>12, :token_length=>2}
    ]
    assert_equal expected, doc.entities
  end

  def test_entities_tokens
    expected = [
      {:text=>"Nat Friedman", :tag=>"PERSON", :score=>1.099661347535191, :token_index=>0, :token_length=>2},
      {:text=>"GitHub", :tag=>"ORGANIZATION", :score=>0.3446416512516501, :token_index=>6, :token_length=>1},
      {:text=>"San Francisco", :tag=>"LOCATION", :score=>1.428241888939011, :token_index=>12, :token_length=>2}
    ]
    assert_equal expected, token_doc.entities
  end

  def test_entities_location
    # would ideally return a single location
    assert_equal ["San Francisco", "California"], model.doc("San Francisco, California").entities.map { |e| e[:text] }
  end

  def test_tokens
    expected = ["Nat", "Friedman", "is", "the", "CEO", "of", "GitHub", ",", "which", "is", "headquartered", "in", "San", "Francisco"]
    assert_equal expected, doc.tokens
  end

  def test_tokens_tokens
    expected = ["Nat", "Friedman", "is", "the", "CEO", "of", "GitHub", ",", "which", "is", "headquartered", "in", "San", "Francisco"]
    assert_equal expected, token_doc.tokens
  end

  def test_tokens_with_offset
    expected = [["Nat", 0], ["Friedman", 4], ["is", 13], ["the", 16], ["CEO", 20], ["of", 24], ["GitHub", 27], [",", 33], ["which", 35], ["is", 41], ["headquartered", 44], ["in", 58], ["San", 61], ["Francisco", 65]]
    assert_equal expected, doc.tokens_with_offset
  end

  def test_tokens_with_offset_tokens
    expected = [["Nat", nil], ["Friedman", nil], ["is", nil], ["the", nil], ["CEO", nil], ["of", nil], ["GitHub", nil], [",", nil], ["which", nil], ["is", nil], ["headquartered", nil], ["in", nil], ["San", nil], ["Francisco", nil]]
    assert_equal expected, token_doc.tokens_with_offset
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

  def token_doc
    model.doc(tokens)
  end

  def tokens
    ["Nat", "Friedman", "is", "the", "CEO", "of", "GitHub", ",", "which", "is", "headquartered", "in", "San", "Francisco"]
  end
end
