require 'rollbar'
require 'minitest/reporters'

module MinitestRollbar
  class << self
    attr_accessor :access_token
  end

  class RollbarReporter < Minitest::Reporters::BaseReporter
    def initialize(options = {})
      super
      @sequential_exception_count = 0
      # Inspect will return ExceptionType + Message.
      # E.g #<Selenium::WebDriver::Error::NoSuchWindowError: Window not found. The browser window may have been closed.>
      # Use this as a criteria of grouping
      @previous_exception_inspect_result = nil
      @previous_exception = nil

      raise 'Must set rollbar access token' if MinitestRollbar.access_token.nil?
      Rollbar.configure do |config|
        config.access_token = MinitestRollbar.access_token
      end
    end

    def record(result)
      super
      if result.error?
        current_exception = result.failure.exception
        current_exception_inspect_result = current_exception.inspect

        # If there is no previous exception, start a fresh counter
        if @previous_exception_inspect_result.nil?
          record_new_error(current_exception)
          # Report or increment the count the previous errors if a new error occurs
        elsif current_exception_inspect_result == @previous_exception_inspect_result
          # Same error, increment counter
          increment_error_counting
        else
          # Different error, report previous errors and record new error
          report_error_to_rollbar
          record_new_error current_exception
        end
      else
        # Report previous errors if there is any
        unless @previous_exception.nil?
          report_error_to_rollbar
          reset_error_counting
        end
      end
    end

    def report
      super
      if @sequential_exception_count > 0
        notifier = Rollbar.scope(count: @sequential_exception_count)
        notifier.error(@previous_exception)

        @previous_exception_inspect_result = nil
        @previous_exception = nil
        @sequential_exception_count = 0

      end
    end

    private

    def report_error_to_rollbar
      notifier = Rollbar.scope(count: @sequential_exception_count)
      notifier.error(@previous_exception)
    end

    def reset_error_counting
      @previous_exception_inspect_result = nil
      @previous_exception = nil
      @sequential_exception_count = 0
    end

    def increment_error_counting
      @sequential_exception_count += 1
    end

    def record_new_error(error)
      @previous_exception_inspect_result = error.inspect
      @previous_exception = error
      @sequential_exception_count = 1
    end
  end
end
