require 'test_helper'
class ReportersTest < Minitest::Test
  def setup
    @reporter = MinitestRollbar::RollbarReporter.new(rollbar_config: {verify_ssl_peer: false, access_token: 'whatever'})
    setup_results
  end

  def test_record__with_two_same_errors_and_one_pass
    mock_notifier = mock
    Rollbar.stubs(:scope).returns(mock_notifier)

    mock_notifier.expects(:error).with('some exception').once

    @reporter.record(@one_result)
    @reporter.record(@one_result)
    @reporter.record(@pass_result)
  end

  def test_record__with_one_error_one_other_error_and_one_pass
    mock_notifier = mock
    Rollbar.stubs(:scope).returns(mock_notifier)
    mock_notifier.expects(:error).with('some exception').once
    mock_notifier.expects(:error).with('other exception').once

    @reporter.record(@one_result)
    @reporter.record(@two_result)
    @reporter.record(@pass_result)
  end

  private

  def setup_results
    # Passed result
    @pass_result = mock

    @pass_result.stubs(:error?).returns(false)
    @pass_result.stubs(:skipped?).returns(false)
    @pass_result.stubs(:passed?).returns(true)
    @pass_result.stubs(:assertions).returns(0)

    @one_result = mock
    @one_result_failure = mock

    # Failure result 1
    @one_result.stubs(:error?).returns(true)
    @one_result.stubs(:skipped?).returns(false)
    @one_result.stubs(:passed?).returns(false)
    @one_result.stubs(:assertions).returns(0)
    @one_result.stubs(:failure).returns(@one_result_failure)
    @one_result_failure.stubs(:exception).returns('some exception')

    # Failure result 2
    @two_result = mock
    @two_result_failure = mock

    @two_result.stubs(:error?).returns(true)
    @two_result.stubs(:skipped?).returns(false)
    @two_result.stubs(:passed?).returns(false)
    @two_result.stubs(:assertions).returns(0)
    @two_result.stubs(:failure).returns(@two_result_failure)
    @two_result_failure.stubs(:exception).returns('other exception')
  end

end
