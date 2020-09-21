# frozen_string_literal: true

require_relative 'lib/minitest_rollbar/version'

Gem::Specification.new do |spec|
  spec.name                  = 'minitest_rollbar'
  spec.version               = MinitestRollbar::VERSION
  spec.platform              = Gem::Platform::RUBY
  spec.authors               = ['AppFolio']
  spec.email                 = ['dev@appfolio.com']
  spec.summary               = 'A minitest reporter that logs test exceptions to Rollbar.'
  spec.description           = spec.summary
  spec.homepage              = 'https://github.com/appfolio/minitest_rollbar'
  spec.licenses              = ['MIT']
  spec.files                 = Dir['**/*'].select { |f| f[%r{^(lib/|Gemfile$|Rakefile|LICENSE.*|README.*|.*gemspec)}] }
  spec.test_files            = spec.files.grep(%r{^(test)/})
  spec.require_paths         = ['lib']

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.add_dependency('minitest-reporters', ['>= 1', '< 2'])
  spec.add_dependency('rollbar', ['>= 2', '< 4'])
end
