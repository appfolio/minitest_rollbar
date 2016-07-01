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

Set up authentication token by:

    MinitestRollbar.access_token = {YOUR_TOKEN}

## License

This gem is available under the Simplified BSD License.

* Copyright (c), 2016, AppFolio, Inc.
