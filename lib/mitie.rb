# stdlib
require "fiddle/import"

# modules
require "mitie/ner"
require "mitie/version"

module Mitie
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end
  self.ffi_lib =
    if Gem.win_platform?
      ["mitie.dll"]
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      ["libmitie.dylib"]
    else
      ["libmitie.so"]
    end

  # friendlier error message
  autoload :FFI, "mitie/ffi"
end
