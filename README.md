# MinitestRollbar

minitest_rollbar is a gem to log test exceptions to rollbar. This is useful in a CI environment to gather statistics on
common exceptions that could indicate infrastructer related issues.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'minitest_rollbar'
```

And then execute:

```bash
  $ bundle install
```

Or install it yourself as:

```bash
  $ gem install minitest_rollbar
```

## Usage

Require necessary files in the test_helper:

```ruby
  require 'minitest_rollbar'
```

Get a reporter with access_token and ssl policy using:

```ruby
  MinitestRollbar::RollbarReporter.new(rollbar_config: { verify_ssl_peer: false, access_token: 'whatever' })
```

By default, occurrences are grouped by string and returned by exception.inspect (Concatenate exception class name and
message). We generate a fingerprint for that. To use rollbar's [default](https://rollbar.com/docs/grouping-algorithm/)
grouping algorithm use:

```ruby
  MinitestRollbar.use_default_grouping = true
```

## License

This gem is available under the MIT License.

* Copyright (c), 2016-2020, AppFolio, Inc.
