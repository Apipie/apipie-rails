[![Gem Version](https://badge.fury.io/rb/rubocop-rake.svg)](https://rubygems.org/gems/rubocop-rake)
![CI](https://github.com/rubocop/rubocop-rake/workflows/main.yml/badge.svg)

# RuboCop Rake

A [RuboCop](https://github.com/rubocop/rubocop) plugin for Rake.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-rake', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rubocop-rake

## Usage

You need to tell RuboCop to load the Rake extension. There are three
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
plugins: rubocop-rake
```

Alternatively, use the following array notation when specifying multiple extensions.

```yaml
plugins:
  - rubocop-other-extension
  - rubocop-rake
```

Now you can run `rubocop` and it will automatically load the RuboCop Rake
cops together with the standard cops.

> [!NOTE]
> The plugin system is supported in RuboCop 1.72+. In earlier versions, use `require` instead of `plugins`.

### Command line

```bash
rubocop --plugin rubocop-rake
```

### Rake task

```ruby
require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.plugins << 'rubocop-rake'
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubocop/rubocop-rake.
