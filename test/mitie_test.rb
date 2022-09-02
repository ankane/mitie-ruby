require_relative "test_helper"

class MitieTest < Minitest::Test
  def test_tokenize
    tokens = Mitie.tokenize(text)
    assert_equal ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"], tokens
    assert tokens.all? { |t| t.encoding == Encoding::UTF_8 }
  end

  def test_tokenize_encoding
    tokens = Mitie.tokenize(text.dup.force_encoding(Encoding::US_ASCII))
    assert tokens.all? { |t| t.encoding == Encoding::US_ASCII }
  end

  def test_tokenize_nil
    assert_equal [], Mitie.tokenize(nil)
  end

  def test_tokenize_file
    tempfile = Tempfile.new
    tempfile.write(text)
    tempfile.flush
    tokens = Mitie.tokenize_file(tempfile.path)
    assert_equal ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"], tokens
    assert tokens.all? { |t| t.encoding == Encoding::ASCII_8BIT }
  end

  def test_tokenize_file_missing
    error = assert_raises(ArgumentError) do
      Mitie.tokenize_file("missing.txt")
    end
    assert_equal "File does not exist", error.message
  end
end
