module Mitie
  class Document
    attr_reader :model, :text

    def initialize(model, text)
      @model = model
      @text = text
    end

    def tokens
      @tokens ||= tokens_with_offset.map(&:first)
    end

    def tokens_with_offset
      @tokens_with_offset ||= begin
        i = 0
        tokens = []
        loop do
          token = (tokens_ptr + i * Fiddle::SIZEOF_VOIDP).ptr
          break if token.null?
          offset = (offsets_ptr.ptr + i * Fiddle::SIZEOF_LONG).to_s(Fiddle::SIZEOF_LONG).unpack1("L!")
          tokens << [token.to_s.force_encoding(text.encoding), offset]
          i += 1
        end
        tokens
      end
    end

    def entities
      @entities ||= begin
        begin
          entities = []
          tokens = tokens_with_offset
          detections = FFI.mitie_extract_entities(pointer, tokens_ptr)
          num_detections = FFI.mitie_ner_get_num_detections(detections)
          num_detections.times do |i|
            pos = FFI.mitie_ner_get_detection_position(detections, i)
            len = FFI.mitie_ner_get_detection_length(detections, i)
            tag = FFI.mitie_ner_get_detection_tagstr(detections, i).to_s
            score = FFI.mitie_ner_get_detection_score(detections, i)
            tok = tokens[pos, len]
            offset = tok[0][1]
            finish = tok[-1][1] + tok[-1][0].size
            entities << {
              text: text[offset...finish],
              tag: tag,
              score: score,
              offset: offset,
              token_index: pos,
              token_length: len
            }
          end
          entities
        ensure
          FFI.mitie_free(detections) if detections
        end
      end
    end

    private

    def pointer
      model.pointer
    end

    def tokens_ptr
      tokenize[0]
    end

    def offsets_ptr
      tokenize[1]
    end

    def tokenize
      @tokenize ||= begin
        offsets_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
        tokens_ptr = FFI.mitie_tokenize_with_offsets(text, offsets_ptr)

        ObjectSpace.define_finalizer(tokens_ptr, self.class.finalize(tokens_ptr))
        ObjectSpace.define_finalizer(offsets_ptr, self.class.finalize_ptr(offsets_ptr))

        [tokens_ptr, offsets_ptr]
      end
    end

    def self.finalize(pointer)
      # must use proc instead of stabby lambda
      proc { FFI.mitie_free(pointer) }
    end

    def self.finalize_ptr(pointer)
      # must use proc instead of stabby lambda
      proc { FFI.mitie_free(pointer.ptr) }
    end
  end
end
