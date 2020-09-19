# frozen_string_literal: true

require 'rollbar'
require 'minitest/reporters'

module MinitestRollbar
  autoload :RollbarReporter, 'minitest_rollbar/rollbar_reporter'
end
