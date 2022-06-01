module Mitie
  module Utils
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
  end
end
