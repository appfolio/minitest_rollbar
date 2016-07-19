require 'rollbar'
require 'minitest/reporters'
module MinitestRollbar
  class << self
    attr_accessor :use_default_grouping
  end

  class RollbarReporter < Minitest::Reporters::BaseReporter
    def initialize(options = {})
      rollbar_config = options.delete(:rollbar_config) || {}
      super(options)

      @sequential_exception_count = 0
      # Inspect will return ExceptionType + Message.
      # E.g #<Selenium::WebDriver::Error::NoSuchWindowError: Window not found. The browser window may have been closed.>
      # Use this as a criteria for log batch grouping
      @previous_exception_inspect_result = nil
      @previous_exception = nil

      Rollbar.configure do |config|
        rollbar_config.each do |key, value|
          config.send "#{key}=", value
        end
      end

      raise 'Must set rollbar access token' if Rollbar.configuration.access_token.nil?
    end

    def record(result)
      super
      if result.error?
        current_exception = result.failure.exception
        current_exception_inspect_result = current_exception.inspect

        if @previous_exception_inspect_result.nil?
          record_new_error(current_exception)
        elsif current_exception_inspect_result == @previous_exception_inspect_result
          increment_error_counting
        else # New exception
          report_error_to_rollbar notifier
          record_new_error current_exception
        end
      else
        unless @previous_exception.nil?
          report_error_to_rollbar notifier
          reset_error_counting
        end
      end
    end

    def report
      super
      if @sequential_exception_count > 0
        report_error_to_rollbar notifier
        reset_error_counting
      end
    end

    private

    def notifier
        if(MinitestRollbar.use_default_grouping.nil?)
          Rollbar.scope({count: @sequential_exception_count,  fingerprint: @previous_exception_inspect_result})
        else
          Rollbar.scope({count: @sequential_exception_count})
        end
    end

    def report_error_to_rollbar(notifier)
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
