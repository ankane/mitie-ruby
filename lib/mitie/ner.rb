module Mitie
  class NER
    attr_reader :pointer

    def initialize(path = nil, pointer: nil)
      if path
        # better error message
        raise ArgumentError, "File does not exist" unless File.exist?(path)
        @pointer = FFI.mitie_load_named_entity_extractor(path)
        @pointer.free = FFI["mitie_free"]
      elsif pointer
        @pointer = pointer
      else
        raise ArgumentError, "Must pass either a path or a pointer"
      end
    end

    def tags
      FFI.mitie_get_num_possible_ner_tags(pointer).times.map do |i|
        FFI.mitie_get_named_entity_tagstr(pointer, i).to_s
      end
    end

    def doc(text)
      Document.new(self, text)
    end

    def entities(text)
      doc(text).entities
    end

    def save_to_disk(filename)
      if FFI.mitie_save_named_entity_extractor(filename, pointer) != 0
        raise Error, "Unable to save model"
      end
      nil
    end

    def tokens(text)
      doc(text).tokens
    end

    def tokens_with_offset(text)
      doc(text).tokens_with_offset
    end
  end
end
