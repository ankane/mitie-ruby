module Mitie
  class NER
    attr_reader :pointer

    def initialize(path)
      # better error message
      raise ArgumentError, "Model file does not exist" unless File.exist?(path)
      @pointer = FFI.mitie_load_named_entity_extractor(path)
      ObjectSpace.define_finalizer(self, self.class.finalize(pointer))
    end

    def tags
      FFI.mitie_get_num_possible_ner_tags(pointer).times.map do |i|
        FFI.mitie_get_named_entity_tagstr(pointer, i).to_s
      end
    end

    def document(text)
      Document.new(self, text)
    end

    def entities(text)
      document(text).entities
    end

    def tokens(text)
      document(text).tokens
    end

    def tokens_with_offset(text)
      document(text).tokens_with_offset
    end

    def self.finalize(pointer)
      # must use proc instead of stabby lambda
      proc { FFI.mitie_free(pointer) }
    end
  end
end
