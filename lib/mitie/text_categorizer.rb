module Mitie
  class TextCategorizer
    def initialize(path = nil, pointer: nil)
      if path
        # better error message
        raise ArgumentError, "File does not exist" unless File.exist?(path)
        @pointer = FFI.mitie_load_text_categorizer(path)
        @pointer.free = FFI["mitie_free"]
      elsif pointer
        @pointer = pointer
      else
        raise ArgumentError, "Must pass either a path or a pointer"
      end
    end

    def categorize(text)
      tokens = text.is_a?(Array) ? text : Mitie.tokenize(text)
      tokens_pointer = Utils.array_to_pointer(tokens)
      text_tag = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      text_score = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE)

      if FFI.mitie_categorize_text(@pointer, tokens_pointer, text_tag, text_score) != 0
        raise Error, "Unable to categorize"
      end

      {
        tag: text_tag.ptr.to_s,
        score: Utils.read_double(text_score)
      }
    ensure
      # text_tag must be freed
      FFI.mitie_free(text_tag.ptr) if text_tag
    end

    def save_to_disk(filename)
      if FFI.mitie_save_text_categorizer(filename, @pointer) != 0
        raise Error, "Unable to save model"
      end
      nil
    end
  end
end
