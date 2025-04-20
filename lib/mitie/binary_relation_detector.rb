module Mitie
  class BinaryRelationDetector
    def initialize(path = nil, pointer: nil)
      if path
        # better error message
        raise ArgumentError, "File does not exist" unless File.exist?(path)
        @pointer = FFI.mitie_load_binary_relation_detector(path)
        @pointer.free = FFI["mitie_free"]
      elsif pointer
        @pointer = pointer
      else
        raise ArgumentError, "Must pass either a path or a pointer"
      end
    end

    def name
      FFI.mitie_binary_relation_detector_name_string(pointer).to_s
    end

    def relations(doc)
      raise ArgumentError, "Expected Mitie::Document, not #{doc.class.name}" unless doc.is_a?(Document)

      entities = doc.entities
      combinations = []
      (entities.size - 1).times do |i|
        combinations << [entities[i], entities[i + 1]]
        combinations << [entities[i + 1], entities[i]]
      end

      relations = []
      combinations.each do |entity1, entity2|
        relation = extract_relation(doc, entity1, entity2)
        relations << relation if relation
      end
      relations
    end

    def save_to_disk(filename)
      if FFI.mitie_save_binary_relation_detector(filename, pointer) != 0
        raise Error, "Unable to save detector"
      end
      nil
    end

    private

    def pointer
      @pointer
    end

    def extract_relation(doc, entity1, entity2)
      relation =
        FFI.mitie_extract_binary_relation(
          doc.model.pointer,
          doc.send(:tokens_ptr),
          entity1[:token_index],
          entity1[:token_length],
          entity2[:token_index],
          entity2[:token_length]
        )

      score_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE)
      status = FFI.mitie_classify_binary_relation(pointer, relation, score_ptr)
      raise Error, "Bad status: #{status}" if status != 0

      score = Utils.read_double(score_ptr)
      if score > 0
        {
          first: entity1[:text],
          second: entity2[:text],
          score: score
        }
      end
    ensure
      FFI.mitie_free(relation) if relation
    end
  end
end
