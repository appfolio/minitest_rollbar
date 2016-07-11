require_relative '../test_helper'
class ReportersTest < Minitest::Test
  def setup
    MinitestRollbar.access_token = 'whatever'
    @reporter =  MinitestRollbar::RollbarReporter.new
  end

  def test_record__with_two_same_errors_and_one_pass
    mock_notifier = Minitest::Mock.new
    mock_notifier.expect(:error, nil, ['some exception'])
    error_result = ResultStub.new
    pass_result = ResultStub.new

    class << pass_result
      def error?
        false
      end
    end

    # Make Rollbar.scope return mocked notifier so we can monitor it's reporting event
    Rollbar.stub(:scope, mock_notifier) do
      @reporter.record(error_result)
      @reporter.record(error_result)
      @reporter.record(pass_result)
      mock_notifier.verify
    end
  end

  def test_record__with_one_error_one_other_error_and_one_pass
    mock_notifier = Minitest::Mock.new
    mock_notifier.expect(:error, nil, ['some exception'])
    mock_notifier.expect(:error, nil, ['other exception'])

    error_result = ResultStub.new
    other_error_result = ResultStub.new
    pass_result = ResultStub.new

    class << pass_result
      def error?
        false
      end
    end

    class << other_error_result
      def failure
        o = Object.new
        class << o
          def exception
            'other exception'
          end
        end
        o
      end
    end

    Rollbar.stub(:scope, mock_notifier) do
      @reporter.record(error_result)
      @reporter.record(other_error_result)
      @reporter.record(pass_result)
      mock_notifier.verify
    end
  end



  class ResultStub
    def error?
      true
    end

    def failure
      o = Object.new
      class << o
        def exception
          'some exception'
        end
      end
      o
    end

    def assertions
      0
    end

    def passed?
      false
    end

    def skipped?
      false
    end
  end
end