require_relative "test_helper"

class BinaryRelationDetectorTest < Minitest::Test
  def test_directed_by
    detector = Mitie::BinaryRelationDetector.new("#{models_path}/binary_relations/rel_classifier_film.film.directed_by.svm")
    assert_equal "film.film.directed_by", detector.name
    doc = model.doc("The Shawshank Redemption was directed by Frank Darabont and starred Tim Robbins and Morgan Freeman")

    binary_relations = detector.binary_relations(doc)
    assert_equal 1, binary_relations.size

    binary_relation = binary_relations.first
    assert_equal "Shawshank Redemption", binary_relation[:first]
    assert_equal "Frank Darabont", binary_relation[:second]
    assert binary_relation[:score]
  end

  def test_place_founded
    detector = Mitie::BinaryRelationDetector.new("#{models_path}/binary_relations/rel_classifier_organization.organization.place_founded.svm")
    assert_equal "organization.organization.place_founded", detector.name
    doc = model.doc("Google was founded in Menlo Park, CA by Larry Page and Sergey Brin")

    binary_relations = detector.binary_relations(doc)
    assert_equal 1, binary_relations.size

    binary_relation = binary_relations.first
    assert_equal "Google", binary_relation[:first]
    assert_equal "Menlo Park", binary_relation[:second]
    assert binary_relation[:score]
  end
end
