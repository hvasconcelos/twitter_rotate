# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twitter_rotate/version'

Gem::Specification.new do |spec|
  spec.name          = "twitter_rotate"
  spec.version       = TwitterRotate::VERSION
  spec.authors       = ["Hélder Vasconcelos"]
  spec.email         = ["heldervasc@bearstouch.com"]
  spec.description   = %q{Command Line Tweet Printer}
  spec.summary       = %q{Command Line Tweet Printer}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib","bin"]
  spec.add_dependency  "colorize", "~> 0.5.8"
  spec.add_dependency  "oauth", "~> 0.4.7"
  spec.add_dependency  "slop", "~> 3.4.5"
  spec.add_dependency  "twitter", "~> 4.8.1"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
