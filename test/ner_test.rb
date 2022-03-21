require_relative "test_helper"

class NERTest < Minitest::Test
  def test_entities
    expected = [
      {:text=>"Nat", :tag=>"PERSON", :score=>0.31123712126883823, :offset=>0, :token_index=>0, :token_length=>1},
      {:text=>"GitHub", :tag=>"LOCATION", :score=>0.5660115198329334, :offset=>13, :token_index=>3, :token_length=>1},
      {:text=>"San Francisco", :tag=>"LOCATION", :score=>1.3890524313885309, :offset=>23, :token_index=>5, :token_length=>2}
    ]
    assert_equal expected, model.entities(text)
  end

  def test_tokens
    expected = ["Nat", "works", "at", "GitHub", "in", "San", "Francisco"]
    assert_equal expected, model.tokens(text)
  end

  def test_tokens_utf8
    assert_equal ["“", "hello", "”"], model.tokens("“hello”")
  end

  def test_tokens_with_offset
    expected = [["Nat", 0], ["works", 4], ["at", 10], ["GitHub", 13], ["in", 20], ["San", 23], ["Francisco", 27]]
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

  def test_save_to_disk
    tempfile = Tempfile.new
    model.save_to_disk(tempfile.path)
    assert File.exist?(tempfile.path)
  ensure
    tempfile.close
    tempfile.unlink
  end

  def test_save_to_disk_error
    error = assert_raises(Mitie::Error) do
      model.save_to_disk("#{Dir.tmpdir}/missing/ner_model.dat")
    end
    assert_equal "Unable to save model", error.message
  end
end
