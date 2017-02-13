# Mail::Secure

Mail::Secure helps the Ruby mail gem send secure messages.

The two ways for secure mail are:
* OpenPGP
* S/MIME

This gem allows you to select different OpenPGP implementations
including NetPGP and GnuPG as different OpenPGP adapters, and also
S/MIME.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mail-secure'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mail-secure

## Usage

```ruby
$ bin/console
#blah
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

