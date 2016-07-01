require_relative 'lib/minitest_rollbar/version'

Gem::Specification.new do |spec|
  spec.author = 'Yuesong Wang'
  spec.email = ['wangyuesong0@qq.com']
  spec.files = Dir.glob('lib/**/*') + %w(LICENSE.txt README.md)
  spec.homepage = 'https://github.com/appfolio/minitest-rollbar'
  spec.license = 'BSD-2-Clause'
  spec.name = 'minitest_rollbar'
  spec.summary = 'A minitest reporter that logs testexceptions to Rollbar.'
  spec.version = MinitestRollbar::VERSION

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'rollbar', '~> 2.0'
  spec.add_runtime_dependency 'minitest', '~> 5.0'
end
