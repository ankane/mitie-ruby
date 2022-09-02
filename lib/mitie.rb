# stdlib
require "fiddle/import"

# modules
require "mitie/binary_relation_detector"
require "mitie/binary_relation_trainer"
require "mitie/document"
require "mitie/ner"
require "mitie/ner_training_instance"
require "mitie/ner_trainer"
require "mitie/text_categorizer"
require "mitie/text_categorizer_trainer"
require "mitie/utils"
require "mitie/version"

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
      tokens_ptr = FFI.mitie_tokenize(text.to_s)
      tokens = read_tokens(tokens_ptr)
      tokens.each { |t| t.force_encoding(text.encoding) }
      tokens
    ensure
      FFI.mitie_free(tokens_ptr) if tokens_ptr
    end

    def tokenize_file(filename)
      raise ArgumentError, "File does not exist" unless File.exist?(filename)
      tokens_ptr = FFI.mitie_tokenize_file(filename)
      read_tokens(tokens_ptr)
    ensure
      FFI.mitie_free(tokens_ptr) if tokens_ptr
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
