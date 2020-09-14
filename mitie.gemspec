require_relative "lib/mitie/version"

Gem::Specification.new do |spec|
  spec.name          = "mitie"
  spec.version       = Mitie::VERSION
  spec.summary       = "Named-entity recognition for Ruby"
  spec.homepage      = "https://github.com/ankane/mitie"
  spec.license       = "BSL-1.0"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{lib,vendor}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.5"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5"
end
