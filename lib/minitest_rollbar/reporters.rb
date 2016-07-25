require 'rollbar'
require 'minitest/reporters'
module MinitestRollbar

  class RollbarReporter < Minitest::Reporters::BaseReporter

    attr_accessor :use_default_grouping

    def initialize(options = {})
      @rollbar_config = options.delete(:rollbar_config) || {}
      super(options)

      @sequential_exception_count = 0
      @use_default_grouping = false
      @previous_exception_inspect_result = nil
      @previous_exception = nil

      # Rollbar global setting, notifier instance won't report if this is not set
      Rollbar.configuration.enabled = true

      raise 'Must set rollbar access token' if @rollbar_config[:access_token].nil?
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

    def git_commit_hash
      ENV['BUILD_VCS_NUMBER']
    end

    def build_config_name
      ENV['TEAMCITY_BUILDCONF_NAME']
    end

    def notifier
      if @use_default_grouping
        @notifier = Rollbar.scope({count: @sequential_exception_count, commit_hash: git_commit_hash, build_config: build_config_name})
      else
        @notifier = Rollbar.scope({count: @sequential_exception_count, commit_hash: git_commit_hash, build_config: build_config_name, fingerprint: @previous_exception_inspect_result})
      end
      @rollbar_config.each do |key,value|
        @notifier.configuration.send("#{key}=", value)
      end
      @notifier
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
