module Mitie
  class BinaryRelationDetector
    def initialize(path)
      # better error message
      raise ArgumentError, "Model file does not exist" unless File.exist?(path)
      @pointer = FFI.mitie_load_binary_relation_detector(path)
      ObjectSpace.define_finalizer(self, self.class.finalize(pointer))
    end

    def name
      FFI.mitie_binary_relation_detector_name_string(pointer).to_s
    end

    def relations(doc)
      entities = doc.entities
      combinations = []
      (entities.size - 1).times do |i|
        combinations << [entities[i], entities[i + 1]]
        combinations << [entities[i + 1], entities[i]]
      end

      relations = []
      combinations.each do |entity1, entity2|
        relation =
          FFI.mitie_extract_binary_relation(
            doc.model.pointer,
            doc.send(:tokens_ptr),
            entity1[:token_index],
            entity1[:token_length],
            entity2[:token_index],
            entity2[:token_length]
          )

        score_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE)
        status = FFI.mitie_classify_binary_relation(pointer, relation, score_ptr)
        raise "Bad status: #{status}" if status != 0
        score = score_ptr.to_s(Fiddle::SIZEOF_DOUBLE).unpack1("d")
        if score > 0
          relations << {
            first: entity1[:text],
            second: entity2[:text],
            score: score
          }
        end
      end
      relations
    end

    private

    def pointer
      @pointer
    end

    def self.finalize(pointer)
      # must use proc instead of stabby lambda
      proc { FFI.mitie_free(pointer) }
    end
  end
end
