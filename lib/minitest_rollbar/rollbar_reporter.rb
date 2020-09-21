# frozen_string_literal: true

module MinitestRollbar
  class RollbarReporter < Minitest::Reporters::BaseReporter
    attr_accessor :use_default_grouping

    def initialize(options = {})
      @rollbar_config = options.delete(:rollbar_config) || {}

      raise StandardError.new('Must set rollbar access token') if @rollbar_config[:access_token].nil?

      super(options)

      @sequential_exception_count = 0
      @use_default_grouping = false
      @previous_exception_inspect_result = nil
      @previous_exception = nil

      # Rollbar global setting, notifier instance won't report if this is not set
      Rollbar.configuration.enabled = true
    end

    def record(result)
      super
      if result.error?
        current_exception = result.failure.exception

        if @previous_exception_inspect_result.nil?
          record_new_error(current_exception)
        elsif current_exception.inspect == @previous_exception_inspect_result
          increment_error_counting
        else # New exception
          report_error_to_rollbar(notifier)
          record_new_error current_exception
        end
      else
        unless @previous_exception.nil?
          report_error_to_rollbar(notifier)
          reset_error_counting
        end
      end
    end

    def report
      super
      if @sequential_exception_count.positive?
        report_error_to_rollbar(notifier)
        reset_error_counting
      end
    end

    private

    def git_commit_hash
      ENV['CIRCLE_SHA1']
    end

    def build_config_name
      ENV['CIRCLE_JOB']
    end

    def notifier
      scope.merge!(fingerprint: @previous_exception_inspect_result) unless @use_default_grouping

      rollbar_notifier = Rollbar.scope(scope)

      @rollbar_config.each { |key, value| rollbar_notifier.configuration.send("#{key}=", value) }

      rollbar_notifier
    end

    def scope
      @scope ||= {
        environment: 'PossibleInfraFlaky',
        count: @sequential_exception_count,
        commit_hash: git_commit_hash,
        build_config: build_config_name
      }
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
