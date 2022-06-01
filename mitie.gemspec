require_relative "lib/mitie/version"

Gem::Specification.new do |spec|
  spec.name          = "mitie"
  spec.version       = Mitie::VERSION
  spec.summary       = "Named-entity recognition for Ruby"
  spec.homepage      = "https://github.com/ankane/mitie-ruby"
  spec.license       = "BSL-1.0"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib,vendor}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.7"
end
