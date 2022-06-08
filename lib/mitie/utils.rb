module Mitie
  module Utils
    def self.tokenize(text)
      tokens_ptr = FFI.mitie_tokenize(text)
      i = 0
      tokens = []
      loop do
        token = (tokens_ptr + i * Fiddle::SIZEOF_VOIDP).ptr
        break if token.null?
        tokens << token.to_s.force_encoding(text.encoding)
        i += 1
      end
      tokens
    end

    def self.array_to_pointer(text)
      # malloc uses memset to set all bytes to 0
      tokens_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP * (text.size + 1))
      text.size.times do |i|
        tokens_ptr[i * Fiddle::SIZEOF_VOIDP, Fiddle::SIZEOF_VOIDP] = Fiddle::Pointer.to_ptr(text[i]).ref
      end
      tokens_ptr
    end

    def self.check_range(range, num_tokens)
      if range.none? || !(0..(num_tokens - 1)).cover?(range)
        raise ArgumentError, "Invalid range"
      end
    end

    def self.read_double(ptr)
      ptr.to_s(Fiddle::SIZEOF_DOUBLE).unpack1("d")
    end
  end
end
