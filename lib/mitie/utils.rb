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
  end
end
