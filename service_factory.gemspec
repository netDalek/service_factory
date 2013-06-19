# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_factory/version'

Gem::Specification.new do |spec|
  spec.name          = "service_factory"
  spec.version       = ServiceFactory::VERSION
  spec.authors       = ["Denis Kirichenko"]
  spec.email         = ["d.kirichenko@fun-box.ru"]
  spec.description   = %q{Service Factory}
  spec.summary       = %q{Service Factory}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rails"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
