# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-flatten-hash"
  spec.version       = "0.5.0"
  spec.authors       = ["Masahiro Sano"]
  spec.email         = ["sabottenda@gmail.com"]
  spec.description   = %q{A fluentd plugin to flatten nested hash structure as a flat record}
  spec.summary       = %q{A fluentd plugin to flatten nested hash structure as a flat record}
  spec.homepage      = "https://github.com/kazegusuri/fluent-plugin-flatten-hash"
  spec.license       = "MIT"
  spec.has_rdoc      = false

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency "fluentd", [">= 0.14.8", "< 2"]
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
end
