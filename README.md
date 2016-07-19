# Minitest-rollbar

Minitest-rollbar is a gem to log test exceptions to rollbar. This is useful in
a CI environment to gather statistics on common exceptions that could indicate
infrastructer related issues.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minitest_rollbar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minitest_rollbar

## Usage

Require necessary files on test_helper:

    require 'minitest_rollbar'

Get a reporter with access_token and ssl policy using:

   @reporter = MinitestRollbar::RollbarReporter.new(rollbar_config: {verify_ssl_peer: false, access_token: 'whatever'})
  
By default we try to group occurrence by string returned by exception.inspect (Concatenate exception class name and message). We generate a fingerprint for that. To use rollbar's [default](https://rollbar.com/docs/grouping-algorithm/) default grouping algorithm, do

    MinitestRollbar.use_default_grouping = true


## License

This gem is available under the Simplified BSD License.

* Copyright (c), 2016, AppFolio, Inc.
