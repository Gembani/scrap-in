lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scrapin/version'

Gem::Specification.new do |spec|
  spec.name          = 'scrapin'
  spec.version       = ScrapIn::VERSION
  spec.authors       = ['Nicholas Stock']
  spec.email         = ['nick@gembani.com']

  spec.summary       = 'LinkedIn automation with Capybara and Selenium'
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  # Prevent pushing this gem to RubyGems.org.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'capybara', '~> 3.40'
  spec.add_dependency 'selenium-webdriver', '~> 4.20'

  spec.add_development_dependency 'dotenv', '~> 3.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.13'
end
