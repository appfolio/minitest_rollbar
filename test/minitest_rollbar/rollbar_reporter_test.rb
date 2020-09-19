# frozen_string_literal: true

require 'test_helper'

module MinitestRollbar
  class ReportersTest < Minitest::Test
    def test_initialize__access_token_not_set
      ex = assert_raises StandardError do
        RollbarReporter.new(rollbar_config: {})
      end

      assert_equal 'Must set rollbar access token', ex.message
    end

    def test_record__with_two_same_errors_and_one_pass
      mock_notifier = mock
      reporter.stubs(:notifier).returns(mock_notifier)

      mock_notifier.expects(:error).with('some exception').once

      reporter.record(one_result)
      reporter.record(one_result)
      reporter.record(pass_result)
    end

    def test_record__with_one_error_one_other_error_and_one_pass
      mock_notifier = mock
      reporter.stubs(:notifier).returns(mock_notifier)
      mock_notifier.expects(:error).with('some exception').once
      mock_notifier.expects(:error).with('other exception').once

      reporter.record(one_result)
      reporter.record(two_result)
      reporter.record(pass_result)
    end

    def test_notifier__with_different_fingerprint
      reporter.stubs(:report_error_to_rollbar).with(anything)
      reporter.record(one_result)
      notifier = reporter.send(:notifier)
      assert_equal '"some exception"', notifier.scope_object[:fingerprint]

      reporter.record(two_result)
      notifier = reporter.send(:notifier)
      assert_equal '"other exception"', notifier.scope_object[:fingerprint]
    end

    def test_notifier__without_default_grouping
      reporter.use_default_grouping = false
      reporter.instance_variable_set('@previous_exception_inspect_result', 'hi')
      notifier = reporter.send(:notifier)
      assert_equal 'hi', notifier.scope_object[:fingerprint]
    end

    def test_notifier__with_default_grouping
      reporter.use_default_grouping = true
      reporter.instance_variable_set('@previous_exception_inspect_result', 'hi')
      notifier = reporter.send(:notifier)
      assert_nil notifier.scope_object[:fingerprint]
    end

    private

    def reporter
      @reporter ||= RollbarReporter.new(rollbar_config: { verify_ssl_peer: false, access_token: 'whatever' })
    end

    def pass_result
      @pass_result ||= begin
        pass_result_mock = mock

        pass_result_mock.stubs(:error?).returns(false)
        pass_result_mock.stubs(:skipped?).returns(false)
        pass_result_mock.stubs(:passed?).returns(true)
        pass_result_mock.stubs(:assertions).returns(0)

        pass_result_mock
      end
    end

    def one_result
      @one_result ||= begin
        one_result_mock = mock
        one_result_failure = mock

        one_result_mock.stubs(:error?).returns(true)
        one_result_mock.stubs(:skipped?).returns(false)
        one_result_mock.stubs(:passed?).returns(false)
        one_result_mock.stubs(:assertions).returns(0)
        one_result_mock.stubs(:failure).returns(one_result_failure)
        one_result_failure.stubs(:exception).returns('some exception')

        one_result_mock
      end
    end

    def two_result
      @two_result ||= begin
        two_result_mock = mock
        two_result_failure = mock

        two_result_mock.stubs(:error?).returns(true)
        two_result_mock.stubs(:skipped?).returns(false)
        two_result_mock.stubs(:passed?).returns(false)
        two_result_mock.stubs(:assertions).returns(0)
        two_result_mock.stubs(:failure).returns(two_result_failure)
        two_result_failure.stubs(:exception).returns('other exception')

        two_result_mock
      end
    end
  end
end
