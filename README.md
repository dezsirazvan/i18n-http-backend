# I18n::Http::Backend

Welcome to I18n::Http::Backend, a gem that provides a remote backend for I18n translations in your Ruby applications. This gem allows you to store your translations in a remote server, such as GitHub, and access them over HTTP.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'i18n-http-backend', git: 'https://github.com/dezsirazvan/i18n-http-backend'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install i18n-http-backend, git: 'https://github.com/dezsirazvan/i18n-http-backend'

## Usage

After the gem is installed you have to create a new i18n.rb initializer in the config/initializers directory of your Rails application. In this initializer, you should add the following code:

example of i18n.rb initializer:

```ruby
require 'i18n/http/backend/runner'

original_backend = I18n::Backend::Simple.new
@cache = ActiveSupport::Cache::MemoryStore.new
I18n.backend = I18n::Http::Backend::Runner.new(original_backend: original_backend, cache: @cache)
```
The cache is optional(it will store in memory as default if not a specific option is given). For the cache option you should send an instance of ActiveSupport::Cache::MemoryStore.new or Redis.new(url: ENV['REDIS_URL'])

By default, the translations will be fetched from the GitHub repository at https://github.com/dezsirazvan/translations. You can change this by passing a base_url option to the http_options argument of I18n::Http::Backend::Runner.new. For example, if you want to fetch translations from a different server, you can use:

```ruby
I18n::Http::Backend::Runner.new(original_backend: original_backend, http_options: { base_url: 'YOUR_NEW_URL_SERVER' })
```
If the http_options: { base_url: 'YOUR_NEW_URL_SERVER' } is not passed, it will use the default remote URL.

The translations should be stored in JSON files named after their language code, such as en.json, fr.json, etc. They should be located in the root directory of the repository on the remote server.
After this configuration is done you can use it like this:

```ruby
I18n.translate('hello') => "the default locale will be :en, so it will try first to find a file called en.json on the remote server and if that file exists and contain a key hello, it will take the remote value. if not, it will try to get the local value for the key hello from the file en.yml"
I18n.translate('hello', locale: :fr)
I18n.t('hello', locale: :es)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/i18n-http-backend.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
