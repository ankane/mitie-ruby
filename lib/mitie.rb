# stdlib
require "fiddle/import"

# modules
require "mitie/document"
require "mitie/ner"
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
      "libmitie.dylib"
    else
      "libmitie.so"
    end
  vendor_lib = File.expand_path("../vendor/#{lib_name}", __dir__)
  self.ffi_lib = [vendor_lib]

  # friendlier error message
  autoload :FFI, "mitie/ffi"
end
