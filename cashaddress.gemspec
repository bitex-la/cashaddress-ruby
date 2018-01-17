# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cashaddress/version"

Gem::Specification.new do |spec|
  spec.name          = "cashaddress"
  spec.version       = Cashaddress::VERSION
  spec.authors       = ["nubis"]
  spec.email         = ["yo@nubis.im"]

  spec.summary       = %q{Convert between bitcoin legacy and cashaddress format}
  spec.description   = %q{Converts between bitcoin legacy and cashaddress formats}
  spec.homepage      = "https://github.com/bitex-la/cashaddress-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
