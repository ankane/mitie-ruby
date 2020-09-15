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
        if text.is_a?(Array)
          # offsets are unknown when given tokens
          text.map { |v| [v, nil] }
        else
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

            entity = {}
            if offset
              finish = tok[-1][1] + tok[-1][0].size
              entity[:text] = text[offset...finish]
            else
              entity[:text] = tok.map(&:first)
            end
            entity[:tag] = tag
            entity[:score] = score
            entity[:offset] = offset if offset
            entity[:token_index] = pos
            entity[:token_length] = len
            entities << entity
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
        if text.is_a?(Array)
          # malloc uses memset to set all bytes to 0
          tokens_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP * (text.size + 1))
          text.size.times do |i|
            tokens_ptr[i * Fiddle::SIZEOF_VOIDP, Fiddle::SIZEOF_VOIDP] = Fiddle::Pointer.to_ptr(text[i]).ref
          end
          [tokens_ptr, nil]
        else
          offsets_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
          tokens_ptr = FFI.mitie_tokenize_with_offsets(text, offsets_ptr)

          ObjectSpace.define_finalizer(tokens_ptr, self.class.finalize(tokens_ptr))
          ObjectSpace.define_finalizer(offsets_ptr, self.class.finalize_ptr(offsets_ptr))

          [tokens_ptr, offsets_ptr]
        end
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
