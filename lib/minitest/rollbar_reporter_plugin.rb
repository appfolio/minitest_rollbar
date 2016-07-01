require 'rollbar'
require 'minitest_rollbar'

module Minitest
  def self.plugin_rollbar_reporter_init(options)
    reporter << MinitestRollbar.ollbarReporter.new(options[:io], options)
  end
end
