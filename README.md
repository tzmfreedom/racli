# Racli

CLI Tool with Rack Application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'racli'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install racli

## Usage

put config.ru
```ruby
run lambda { |env| [200, {}, ['hello']] }
```

Run racli on directory where you put config.ru.
```bash
racli
```

By default, racli requests root path, that is '/', with GET method. 
You can specify HTTP method and path.
```bash
racli {METHOD} {PATH} # ex) racli POST /users
```

The rack configuration file is `config.ru` on current directory by default.
If you want to use other file as rack configuration file, you should specify `--config` option
```bash
racli --config /path/to/config_file
```

If you want to add rack response handler, you should put .raclirc on the same directory as config.ru is put.
The following is sample .raclirc
```ruby
add_handler Racli::Handlers::RetryHandler
# add_handler Racli::Handlers::DebugHandler
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/racli.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
