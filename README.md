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

Imagine a situation where we want to update an appointment, notify the user of that update,
and publish it in google calendar if needed:

```ruby
class Find
  include WFlow::Process

  # helper for flow.data
  data_reader :appointment_id
  data_writer :appointment

  # perform is the name of the method that will be invoked when calling 'run'
  def perform
    self.appointment = Appointment.find(appointment_id)

    # the previous code is the same as:
    # flow.data.appointment = Appointment.find(flow.data.appointment_id)
  end
end

class UpdateAppointment
  include WFlow::Process

  execute Find, Update, NotifyUser

  execute PublishInGoogleCalendar, if: :publish_in_google_calendar?

protected

  def publish_in_google_calendar?
    flow.data.appointment.synch_in_google_calendar?
  end
end

# imagining that we have the id of the appointment to be updated and the new attributes for the appointment
report = UpdateAppointment.run(appointment_id: appointment_id, attributes: new_attributes)

# ask if workflow was a success
report.success?
```

So what's going on here? We first declare a class and included the module WFlow::Process, so that
we can compose the workflow for this process:

```ruby
class UpdateAppointment
  include WFlow::Process
```

Now we can start composing. We compose by reusing other processes like this:

```ruby
  # this indicates that it will first Find, Update next and NotifyUser last
  execute Find, Update, NotifyUser

  # execute this process, only if method returns true
  execute PublishInGoogleCalendar, if: :publish_in_google_calendar?
```

TODO: more documentation

## Contributing

1. Fork it ( https://github.com/junhanamaki/w_flow/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
