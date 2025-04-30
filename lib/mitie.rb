# stdlib
require "fiddle/import"

# modules
require_relative "mitie/binary_relation_detector"
require_relative "mitie/binary_relation_trainer"
require_relative "mitie/document"
require_relative "mitie/ner"
require_relative "mitie/ner_training_instance"
require_relative "mitie/ner_trainer"
require_relative "mitie/text_categorizer"
require_relative "mitie/text_categorizer_trainer"
require_relative "mitie/utils"
require_relative "mitie/version"

module Mitie
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end
  lib_name =
    if Gem.win_platform?
      "mitie.dll"
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        "libmitie.arm64.dylib"
      else
        "libmitie.dylib"
      end
    else
      "libmitie.so"
    end
  vendor_lib = File.expand_path("../vendor/#{lib_name}", __dir__)
  self.ffi_lib = [vendor_lib]

  # friendlier error message
  autoload :FFI, "mitie/ffi"

  class << self
    def tokenize(text)
      tokens_ptr = FFI.mitie_tokenize(+text.to_s)
      tokens_ptr.free = FFI["mitie_free"]
      tokens = read_tokens(tokens_ptr)
      tokens.each { |t| t.force_encoding(text.encoding) }
      tokens
    end

    def tokenize_file(filename)
      raise ArgumentError, "File does not exist" unless File.exist?(filename)
      tokens_ptr = FFI.mitie_tokenize_file(+filename)
      tokens_ptr.free = FFI["mitie_free"]
      read_tokens(tokens_ptr)
    end

    private

    def read_tokens(tokens_ptr)
      i = 0
      tokens = []
      loop do
        token = (tokens_ptr + i * Fiddle::SIZEOF_VOIDP).ptr
        break if token.null?
        tokens << token.to_s
        i += 1
      end
      tokens
    end
  end
end
