# Anonymous
[![Gem Version](https://badge.fury.io/rb/anonymous.svg)](https://badge.fury.io/rb/anonymous)
[![Build Status](https://travis-ci.com/jamesstonehill/anonymous.svg?branch=master)](https://travis-ci.com/jamesstonehill/anonymous)

Anonymous is a light-weight gem that makes anonymizing ActiveRecord models easy!
Remember, friends don't let friends use production data in
staging/development.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anonymous'
```

And then execute:

    $ bundle

## Usage

### Usage With ActiveRecord
To use this gem in your ActiveRecord models you need to do two things.
1. Include the `Anonymous::ActiveRecord` module in your model
2. Define a private method `anonymization_definitions` with the anonymization
   definitions inside it.

```ruby
class User < ApplicationRecord
  include Anonymous::ActiveRecord

  private

  def anonymization_definitions
    {
      name: ["Bob Dylan", "Tony Blair"].sample,
      email: -> (user_email) { "fake_#{user_email}" },
      phone_number: -> (phone) { phone[0..-4] + 3.times.map{rand(10)}.join },
    }
  end
end
```

The return value of `anonymization_definitions` should be a Hash where the keys
are the names of the attribute to be anonymized and the values are either a
`Proc` object or the value to be filled in for the anonymized attribute.

If you use a proc or lambda as the argument then the attribute value will be
provided to you in the proc's first argument. This is useful when you want your
anonymized value to be a transformation of the original.

It is recommended that you use this gem in conjunction with a fake data
generation library like [faker](https://github.com/stympy/faker).

```ruby
  def anonymization_definitions
    {
      first_name: Faker::Name.first_name,
      email: Faker::Internet.unique.email,
    }
  end
```

Then when you have set up the gem correctly you can call `anonymize` and
`anonymize!` on the model.

```ruby
user = User.create(
  name: "John Smith",
  email: "john.smith@example.com",
  phone_number: "+447875477389"
)
user.anonymize! # or user.anonymize
user.reload
user.email
=> "fake_john.smith@example.com"
user.name
=> "Bob Dylan"
user.phone_number
=> "+447875477412"
```

The only difference between `anonymize!` and `anonymize` is that the former
calls `update!` and the latter calls `update`.

## Configuration

You can configure the gem to alter the anonymisation behaviour.

```ruby
# config/initializers/anonymous.rb

Anonymous.configure do |config|
  config.max_anonymize_retries = 0
end
```

### Configuration Options

1. max_anonymize_retries
Under some situations (like if an RecordNotUnique error is raised when updating)
the gem will retry the anonymization process. By default it will only do this
once.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake appraisal spec` to run the tests. You can also run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/jamesstonehill/anonymous.

Some ideas for feature contributions:
- Support for ORMs other than ActiveRecord.
- More comprehensive retry functionality in Anonymous::ActiveRecord. A the
    moment we only retry if we get an ActiveRecord::RecordNotUnique unique
    error. I didn't want to blindly rescue all errors, but it seems like that
    there are other times we would want to retry.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
