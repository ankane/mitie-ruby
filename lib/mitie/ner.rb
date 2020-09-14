module Mitie
  class NER
    def initialize(path)
      @pointer = FFI.mitie_load_named_entity_extractor(path)
      ObjectSpace.define_finalizer(self, self.class.finalize(pointer))
    end

    def tags
      FFI.mitie_get_num_possible_ner_tags(pointer).times.map do |i|
        FFI.mitie_get_named_entity_tagstr(pointer, i).to_s
      end
    end

    def tokens(text)
      tokens = []
      ptr = FFI.mitie_tokenize(text)
      i = 0
      loop do
        token = (ptr + i * Fiddle::SIZEOF_VOIDP).ptr
        break if token.null?
        tokens << token.to_s.force_encoding(text.encoding)
        i += 1
      end
      tokens
    ensure
      FFI.mitie_free(ptr) if ptr
    end

    def tokens_with_offset(text)
      tokens, ptr = tokens_with_offset_with_ptr(text)
      tokens
    ensure
      FFI.mitie_free(ptr) if ptr
    end

    def entities(text)
      entities = []
      tokens, tokens_ptr = tokens_with_offset_with_ptr(text)
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
          offset: offset
        }
      end
      entities
    ensure
      FFI.mitie_free(tokens_ptr) if tokens_ptr
      FFI.mitie_free(detections) if detections
    end

    private

    def pointer
      @pointer
    end

    def tokens_with_offset_with_ptr(text)
      token_offsets = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
      ptr = FFI.mitie_tokenize_with_offsets(text, token_offsets)
      i = 0
      tokens = []
      loop do
        token = (ptr + i * Fiddle::SIZEOF_VOIDP).ptr
        break if token.null?
        offset = (token_offsets.ptr + i * Fiddle::SIZEOF_LONG).to_s(Fiddle::SIZEOF_LONG).unpack1("L!")
        tokens << [token.to_s.force_encoding(text.encoding), offset]
        i += 1
      end
      [tokens, ptr]
    ensure
      # use ptr, not token_offsets.ptr
      FFI.mitie_free(token_offsets.ptr) if ptr
    end

    def self.finalize(pointer)
      # must use proc instead of stabby lambda
      proc { FFI.mitie_free(pointer) }
    end
  end
end
