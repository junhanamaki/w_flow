# WFlow

[![Gem Version](https://badge.fury.io/rb/w_flow.svg)](http://badge.fury.io/rb/w_flow)
[![Build Status](https://travis-ci.org/junhanamaki/w_flow.svg?branch=master)](https://travis-ci.org/junhanamaki/w_flow)
[![Code Climate](https://codeclimate.com/github/junhanamaki/w_flow.png)](https://codeclimate.com/github/junhanamaki/w_flow)
[![Test Coverage](https://codeclimate.com/github/junhanamaki/w_flow/coverage.png)](https://codeclimate.com/github/junhanamaki/w_flow)
[![Dependency Status](https://gemnasium.com/junhanamaki/w_flow.svg)](https://gemnasium.com/junhanamaki/w_flow)

WFlow aims to help on designing workflows based on [Single
Responsibility Principle](http://en.wikipedia.org/wiki/Single_responsibility_principle). WFlow
proposes to achieve this by providing tools to build classes where each are responsible for a task
and one task only, and by providing tools to compose these classes.

Word of appreciation for [usecasing](https://github.com/tdantas/usecasing),
[interactor](https://github.com/collectiveidea/interactor) and
[rest_my_case](https://github.com/goncalvesjoao/rest_my_case) that served as
inspiration for this gem.

## Dependencies

Tested with:

  * ruby 2.2.1, 2.2.0, 2.1.1, 2.0.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'w_flow'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install w_flow

## Usage

On its most simplest form a task (in WFlow called a Process) is something like this:

```ruby
class SaveUser
  include WFlow::Process

  def perform
    # arguments passed to run will be under flow.data
    flow.data.user.save
  end
end

# run process, it will return a report object
report = SaveUser.run(user: current_user)

report.success?
```



## Contributing

1. Fork it ( https://github.com/junhanamaki/w_flow/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
