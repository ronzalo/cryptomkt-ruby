# Cryptomkt Ruby wrapper

Wrapper for Cryptomkt API, check documentation at [https://developers.cryptomkt.com/es](https://developers.cryptomkt.com/es/?shell#obtener-balance) and get credentials in [www.cryptomkt.com](https://www.cryptomkt.com/account#api_tab)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cryptomkt-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cryptomkt-ruby

## Usage

client = CryptomktRuby::Client.new(key, secret)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ronzalo/cryptomkt-ruby.

## TODO

Implement CryptoCompra
