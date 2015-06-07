# WFlow

[![Gem Version](https://badge.fury.io/rb/w_flow.svg)](http://badge.fury.io/rb/w_flow)
[![Build Status](https://travis-ci.org/junhanamaki/w_flow.svg?branch=master)](https://travis-ci.org/junhanamaki/w_flow)
[![Code Climate](https://codeclimate.com/github/junhanamaki/w_flow.png)](https://codeclimate.com/github/junhanamaki/w_flow)
[![Test Coverage](https://codeclimate.com/github/junhanamaki/w_flow/coverage.png)](https://codeclimate.com/github/junhanamaki/w_flow)
[![Dependency Status](https://gemnasium.com/junhanamaki/w_flow.svg)](https://gemnasium.com/junhanamaki/w_flow)

WFlow aims to help on designing workflows based on [Single
Responsibility Principle](http://en.wikipedia.org/wiki/Single_responsibility_principle). WFlow
proposes to achieve this by providing tools to help compose those classes into a workflow.

Word of appreciation for [usecasing](https://github.com/tdantas/usecasing),
[interactor](https://github.com/collectiveidea/interactor) and
[rest_my_case](https://github.com/goncalvesjoao/rest_my_case) that served as
inspiration for this gem.

## Dependencies

Tested with:

  * ruby 2.2.2, 2.2.1, 2.2.0, 2.1.1, 2.0.0

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

In its most simplest form a Process would look like this:

```ruby
# Process to retrive a user from the database given a user_id
class FindUser
  # include module Process
  include WFlow::Process

  # perform is where you'll execute your business logic
  def perform
    # flow is an object present in a Process, and it is how you retrieve data
    # from the current flow, in this case the input user_id
    user_id = flow.data.user_id

    # when you want to output a value from the Process you set it in data
    flow.data.user = User.find(user_id)
  end
end
```

And you invoke it like this:

```ruby
# run will returns a report object
report = FindUser.run(user_id: 10)

# this report object will contain the output from the Process
report.data.user
```

This and any other Process can be used to compose a workflow, so lets try that:

```ruby
class SendWelcomeEmail
  include WFlow::Process

  # use previously created Process to find the user
  execute FindUser

  def perform
    # code to send email to user
  end
end

report = SendWelcomeEmail.run(user_id: 10)
```

Processes passed to execute will be called before the perform method. You can
have as any execute as you want and as many Processes (and method nomes and Procs) in a execute.
This means that when you run SendWelcomeEmail process, it will first execute FindUser which will
set the user under flow.data, and then you can use that user to get the email address
for where to send the email.

So far so good, but lets go back to FindUser. Looking at it, we are currently not accounting for
errors cases, like what should happen when we can't find an user, or when the connection to the
database fails? This depends on what you want to do, but for this example we'll raise a flow failure,
and we'll also simplify the code a bit using data helpers:

```ruby
class FindUser
  include WFlow::Process

  # helper methods to access attributes under flow.data
  data_reader   :user_id
  data_accessor :user

  def perform
    self.user = User.find(user_id)
  rescue
    # you can pass whatever you want to the failure! method (or even call it without arguments)
    # passed value will be available in returned report under failure_log
    flow.failure!('unable to find user')
  end
end

report = FindUser.run(user_id: 10)

# check if success
unless report.success? # there's also a report.failure?
  # failure_log is an array that contains all the objects passed to failure!
  report.failure_log.each do |log|
    puts log
  end
end
```

Invoking failure! will interrupt a workflow immediatly. This means that if you run
SendWelcomeEmail for a non existing user it will never run the code under perform (which
is a good thing, since there's no one to send the email to). But what if we want to do
something more even in case of failure? You can pass a handler for that:

```ruby
class SendWelcomeEmail
  include WFlow::Process

  attr_writer :admin_email

  # you can pass a name or a proc as a failure handler, which will be called if one
  # of the Processes in execute chain raises a flow failure
  execute FindUser, failure: :on_failure

  # we'll use an if handler (there's also an unless handler), which allows us to control if a execute chain
  # should be executed or not
  execute :compose_email, SendMessageToAdmin, -> { flow.failure! }, if: -> { @no_user_found }

  def perform
    # ...
  end

protected

  # failure handler, return false to cancel failure, or true to let Process fail
  def on_failure
    @no_user_found = true

    false
  end

  def compose_email
    self.admin_email = "we were unable to find user :("
  end
end
```

Wow it suddenly become complex, but it reflects a more realistic situation. So what's
going on? First we try to find the user, which will raise a flow failure if no user
is found. In this case we want to inform the admin that something went wrong, so instead of allowing
the flow to be interrupted right away, we return false in the failure handler to cancel failure.
After that, the second execute chain will be executed, because @no_user_found is set to true. This
execution chain will invoke the method compose_email, SendMessageToAdmin, and
call proc that reraises failure.

This is some of the features of WFlow, please check [wiki](https://github.com/junhanamaki/w_flow/wiki) for more details.

## Contributing

1. Fork it ( https://github.com/junhanamaki/w_flow/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
