require_relative "test_helper"

class MitieTest < Minitest::Test
  def test_tokenize
    expected = ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"]
    assert_equal expected, Mitie.tokenize(text)
  end
end
