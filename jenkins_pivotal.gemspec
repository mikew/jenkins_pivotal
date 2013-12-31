# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jenkins_pivotal/version'

Gem::Specification.new do |spec|
  spec.name          = "jenkins_pivotal"
  spec.version       = JenkinsPivotal::VERSION
  spec.authors       = ["Mike Wyatt"]
  spec.email         = ["wyatt.mike@gmail.com"]
  spec.summary       = %q{Jenkins git changelog -> Pivotal Tracker}
  spec.description   = %q{Jenkins git changelog -> Pivotal Tracker}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
