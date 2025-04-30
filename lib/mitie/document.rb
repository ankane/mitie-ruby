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
            offset = (offsets_ptr + i * Fiddle::SIZEOF_LONG).to_str(Fiddle::SIZEOF_LONG).unpack1("L!")
            tokens << [token.to_s.force_encoding(text.encoding), offset]
            i += 1
          end
          tokens
        end
      end
    end

    def entities
      @entities ||= begin
        entities = []
        tokens = tokens_with_offset
        detections = FFI.mitie_extract_entities(pointer, tokens_ptr)
        detections.free = FFI["mitie_free"]
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
            finish = tok[-1][1] + tok[-1][0].bytesize
            entity[:text] = text.byteslice(offset...finish)
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
          tokens_ptr = Utils.array_to_pointer(text)
          [tokens_ptr, nil]
        else
          offsets_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE)
          tokens_ptr = FFI.mitie_tokenize_with_offsets(+text, offsets_ptr)
          tokens_ptr.free = FFI["mitie_free"]
          offsets_ptr = offsets_ptr.ptr
          offsets_ptr.free = FFI["mitie_free"]

          [tokens_ptr, offsets_ptr]
        end
      end
    end
  end
end
