require_relative '../test_helper'
class ReportersTest < Minitest::Test
  def setup
    MinitestRollbar.access_token = 'whatever'å
    @reporter =  MinitestRollbar::RollbarReporter.new
  end
  def test_record
    mock_notifier = Minitest::Mock.new
    mock_notifier.expect(:error, nil)
    mock_error_result = Object.new
    class << mock_error_result
      def error?
        true
      end
      def failure
        o = Object.new
        class << o
          def exception
            ['some', 'exception']
          end
        end
        o
      end
    end
    mock_pass_result = Object.new
    class << mock_pass_result
      def error?
        false
      end
    end

    Rollbar.stub(:scope, mock_notifier) do
      @reporter.record(mock_error_result)
      @reporter.record(mock_error_result)
      @reporter.record(mock_pass_result)
      mock_notifier.verify
    end
  end
end