require_relative "test_helper"

class MitieTest < Minitest::Test
  def test_tokenize
    expected = ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"]
    assert_equal expected, Mitie.tokenize(text)
  end

  def test_tokenize_ascii
    tokens = Mitie.tokenize(text.dup.force_encoding(Encoding::US_ASCII))
    assert tokens.all? { |t| t.encoding == Encoding::US_ASCII }
  end

  def test_tokenize_file
    tempfile = Tempfile.new
    tempfile.write(text)
    tempfile.flush
    expected = ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"]
    tokens = Mitie.tokenize_file(tempfile.path)
    assert_equal expected, tokens
    assert tokens.all? { |t| t.encoding == Encoding::ASCII_8BIT }
  end
end
