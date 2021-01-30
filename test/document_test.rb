require_relative "test_helper"

class DocumentTest < Minitest::Test
  def test_entities
    expected = [
      {:text=>"Nat", :tag=>"PERSON", :score=>0.31123712126883823, :offset=>0, :token_index=>0, :token_length=>1},
      {:text=>"GitHub", :tag=>"LOCATION", :score=>0.5660115198329334, :offset=>13, :token_index=>3, :token_length=>1},
      {:text=>"San Francisco", :tag=>"LOCATION", :score=>1.3890524313885309, :offset=>23, :token_index=>5, :token_length=>2}
    ]
    assert_equal expected, doc.entities
  end

  def test_entities_tokens
    expected = [
      {:text=>["Nat"], :tag=>"PERSON", :score=>0.31123712126883823, :token_index=>0, :token_length=>1},
      {:text=>["GitHub"], :tag=>"LOCATION", :score=>0.5660115198329334, :token_index=>3, :token_length=>1},
      {:text=>["San", "Francisco"], :tag=>"LOCATION", :score=>1.3890524313885309, :token_index=>5, :token_length=>2}
    ]
    assert_equal expected, token_doc.entities
  end

  def test_entities_location
    # would ideally return a single location
    assert_equal ["San Francisco", "California"], model.doc("San Francisco, California").entities.map { |e| e[:text] }
  end

  def test_entities_byte_order_mark
    expected = [{:text=>"California", :tag=>"LOCATION", :score=>1.4244816233933328, :offset=>12, :token_index=>2, :token_length=>1}]
    assert_equal expected, model.doc("\xEF\xBB\xBFWorks in California").entities
  end

  def test_tokens
    expected = ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"]
    assert_equal expected, doc.tokens
  end

  def test_tokens_tokens
    expected = ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"]
    assert_equal expected, token_doc.tokens
  end

  def test_tokens_with_offset
    expected = [["Nat", 0], ["works", 4], ["at", 10], ["GitHub", 13], ["in", 20], ["San", 23], ["Francisco", 27]]
    assert_equal expected, doc.tokens_with_offset
  end

  def test_tokens_with_offset_tokens
    expected =[["Nat", nil], ["works", nil], ["at", nil], ["GitHub", nil], ["in", nil], ["San", nil], ["Francisco", nil]]
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
    ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"]
  end
end
