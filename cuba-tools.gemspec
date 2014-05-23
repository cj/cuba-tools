# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "cuba-tools"
  spec.version       = "0.0.6"
  spec.authors       = ["cj"]
  spec.email         = ["cjlazell@gmail.com"]
  spec.description   = %q{Contains a group of tools to extend cuba}
  spec.summary       = %q{Tools to extend cuba}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cuba", "~> 3.1.1"
  spec.add_dependency "shield", "~> 2.1.0"
  spec.add_dependency "signature-acd", "~> 0.1.11"
  spec.add_dependency "mab", "~> 0.0.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cutest-cj"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "tilt"
  spec.add_development_dependency "slim"
end
