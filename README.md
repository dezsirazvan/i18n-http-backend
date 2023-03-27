# I18n::Http::Backend

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/i18n/http/backend`. To experiment with that code, run `bin/console` for an interactive prompt.

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

After the gem is installed you have to create a new i18n.rb initializer and to add this code on it. The cache is optional(it will store in memory as default if not a specific option is given). For the cache option you should send an instance of ActiveSupport::Cache::MemoryStore.new or Redis.new(url: ENV['REDIS_URL'])

example of i18n.rb initializer:

```ruby
require 'i18n/http/backend/runner'

original_backend = I18n::Backend::Simple.new
@cache = ActiveSupport::Cache::MemoryStore.new
I18n.backend = I18n::Http::Backend::Runner.new(original_backend: original_backend, cache: @cache)
```

for the Runner you can pass also a variable called http_options with a new base_url if you want to use another remote server.

```ruby
I18n::Http::Backend::Runner.new(original_backend: original_backend, http_options: { base_url: 'YOUR_NEW_URL_SERVER' })
```
If the http_options: { base_url: 'YOUR_NEW_URL_SERVER' } is not passed, it will use my github project as a default remote url.
I created a new github project just to store some jsons: https://github.com/dezsirazvan/translations. I named the files like this: {language}.json. So if you want to use another remote server, the files should be stored the same: REMOTE_SERVER/en.json, REMOTE_SERVER/fr.json in order to work with the current logic.

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
