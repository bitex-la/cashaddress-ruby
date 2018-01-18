# Cashaddress

Converts between bitcoin cash cashaddress and legacy bitcoin address format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cashaddress'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cashaddress

## Usage

```ruby
   > Cashaddress.from_legacy('1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu')
   => 'bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a',
   > Cashaddress.to_legacy('bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a')
   => '1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bitex-la/cashaddress-ruby

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
