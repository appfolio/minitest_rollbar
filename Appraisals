# frozen_string_literal: true

case RUBY_VERSION
when '2.7.1'
  appraise "ruby-#{RUBY_VERSION}_rollbar2" do
    gem 'rollbar', '~> 2.0'
  end

  appraise "ruby-#{RUBY_VERSION}_rollbar3" do
    gem 'rollbar', '~> 3.0'
  end
when '2.6.3'
  appraise "ruby-#{RUBY_VERSION}_rollbar2" do
    gem 'rollbar', '~> 2.0'
  end

  appraise "ruby-#{RUBY_VERSION}_rollbar3" do
    gem 'rollbar', '~> 3.0'
  end
else
  raise "Unsupported Ruby version #{RUBY_VERSION}"
end
