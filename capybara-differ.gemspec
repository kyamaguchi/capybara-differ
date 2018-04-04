lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capybara-differ/version"

Gem::Specification.new do |spec|
  spec.name          = "capybara-differ"
  spec.version       = Capybara::Differ::VERSION
  spec.authors       = ["Kazuho Yamaguchi"]
  spec.email         = ["kzh.yap@gmail.com"]

  spec.summary       = %q{Snapshot pages and display diff to help refactoring.}
  spec.description   = %q{Snapshot pages and display diff to help refactoring.}
  spec.homepage      = "https://github.com/kyamaguchi/capybara-differ"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara"
  spec.add_dependency "selenium-webdriver"
  spec.add_dependency "htmlbeautifier"
  spec.add_dependency "diffy"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug"
end
