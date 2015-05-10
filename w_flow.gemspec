# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'w_flow/version'

Gem::Specification.new do |spec|
  spec.name          = "w_flow"
  spec.version       = WFlow::VERSION
  spec.authors       = ["junhanamaki"]
  spec.email         = ["jun.hanamaki@gmail.com"]

  spec.summary       = %q{A workflow composer based on Single Responsability Principle to help organize projects}
  spec.description   = %q{WFlow is a workflow composer that helps in organizing projects by splitting logic into reusable modules (processes)}
  spec.homepage      = "https://github.com/junhanamaki/w_flow"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",   "~> 1.9"
  spec.add_development_dependency "rspec",     '~> 3.2'
  spec.add_development_dependency "pry",       '~> 0.10'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
end
