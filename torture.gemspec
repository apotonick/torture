lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'torture/version'

Gem::Specification.new do |spec|
  spec.name          = "torture"
  spec.version       = Torture::VERSION
  spec.authors       = ["Nick Sutterer"]
  spec.email         = ["apotonick@gmail.com"]

  spec.summary       = %q{Tool collection to write and layout programmer's manuals.}
  spec.description   = %q{Tool collection to write and layout programmer's manuals.}
  spec.homepage      = "https://github.com/apotonick/torture"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "kramdown"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "5.10.0"
  spec.add_development_dependency "test_xml"
end
