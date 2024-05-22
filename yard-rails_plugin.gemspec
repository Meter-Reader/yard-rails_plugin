# frozen_string_literal: true

require 'English'
require File.expand_path('lib/yard-rails_plugin/version', __dir__)

Gem::Specification.new do |gem|
  gem.required_ruby_version = '~> 3.3'
  gem.authors       = ['Peter Nagy']
  gem.email         = ['peter@meter-reader.com']
  gem.summary       = 'YARD plugin to document a Rails project'
  gem.homepage      = 'https://github.com/Meter-reader/yard-rails_plugin'
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'yard-rails_plugin'
  gem.require_paths = ['lib']
  gem.version       = YARD::Rails::Plugin::VERSION

  gem.add_runtime_dependency 'yard', '~> 0.7', '> 0.7'
  gem.add_development_dependency 'rake', '~> 13.2'
  gem.add_development_dependency 'rubocop', '~> 1.63'
end
