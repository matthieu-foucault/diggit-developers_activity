# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'diggit/developers_activity/version'

Gem::Specification.new do |spec|
  spec.name          = "diggit-developers_activity"
  spec.version       = Diggit::DevelopersActivity::VERSION
  spec.authors       = ["Matthieu Foucault"]
  spec.email         = ["foucault.matthieu@gmail.com"]
  spec.summary       = "Analyses and dataset for the diggit tool."
  spec.description   = "This gem contains a set of analyses extracting developers activity from git repositories,
  using different granularities of time periods. It also includes a dataset of git repositories for which we extacted
  the identity of bug-fixing commits for a given release, as well as author identity merge information."
  spec.homepage      = ""
  spec.license       = "LGPL"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "diggit", "~> 2.0"
end
