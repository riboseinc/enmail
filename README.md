# EnMail

[![CircleCI](https://circleci.com/gh/abunashir/mail-secure/tree/master.svg?style=svg&circle-token=5f553bfa04e22b7f5d2e393afe0859595e6db6d5)](https://circleci.com/gh/abunashir/mail-secure/tree/master)

EnMail (Encrypted mail) helps the Ruby mail gem send secure encrypted messages.

The two ways for secure mail are:
* OpenPGP
* S/MIME

This gem allows you to select different OpenPGP implementations
including NetPGP and GnuPG as different OpenPGP adapters, and also
S/MIME.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "enmail"
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install enmail
```

## Configure

The `EnMail` gem provides a very easier interface to set custom configurations
or configure the underlying dependencies, we can configure it by adding an
initializer with the following code

```ruby
EnMail.configure do |config|
  config.certificates_path = "CERTIFICATES_ROOT_PAH"
end
```

Or

```ruby
EnMail.configuration.certificates_path = "CERTIFICATES_ROOT_PAH"
```

## Usage

```sh
bin/console
```

## Development

We are following Sandi Metz's Rules for this gem, you can read the
[description of the rules here][sandimetz]. All new code should follow these
rules. If you make changes in a pre-existing file that violates these rules you
should fix the violations as part of your contribution.

### Setup

Clone the repository.

```sh
git clone https://github.com/riboseinc/enmail
```

Setup your environment.

```sh
bin/setup
```

Run the test suite

```sh
bin/rspec
```

## Contributing

First, thank you for contributing! We love pull requests from everyone. By
participating in this project, you hereby grant [Ribose Inc.][ribose] the
right to grant or transfer an unlimited number of non exclusive licenses or
sub-licenses to third parties, under the copyright covering the contribution
to use the contribution by all means.

Here are a few technical guidelines to follow:

1. Open an [issue][issues] to discuss a new feature.
1. Write tests to support your new feature.
1. Make sure the entire test suite passes locally and on CI.
1. Open a Pull Request.
1. [Squash your commits][squash] after receiving feedback.
1. Party!

## Credits

This gem is developed, maintained and funded by [Ribose Inc.][ribose]

[ribose]: https://www.ribose.com
[issues]: https://github.com/abunashir/enmail/issues
[squash]: https://github.com/thoughtbot/guides/tree/master/protocol/git#write-a-feature
[sandimetz]: http://robots.thoughtbot.com/post/50655960596/sandi-metz-rules-for-developers
