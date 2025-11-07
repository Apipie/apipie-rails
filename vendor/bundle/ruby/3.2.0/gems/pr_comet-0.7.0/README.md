# PrComet

[![CircleCI](https://circleci.com/gh/ryz310/pr_comet.svg?style=svg)](https://circleci.com/gh/ryz310/pr_comet) [![Gem Version](https://badge.fury.io/rb/pr_comet.svg)](https://badge.fury.io/rb/pr_comet) [![Maintainability](https://api.codeclimate.com/v1/badges/962618c106a548ed762b/maintainability)](https://codeclimate.com/github/ryz310/pr_comet/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/962618c106a548ed762b/test_coverage)](https://codeclimate.com/github/ryz310/pr_comet/test_coverage)

A helper library that makes it easy to create pull requests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pr_comet'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pr_comet

## Usage

```ruby
# Initialize.
pr_comet = PrComet.new(base: 'master', branch: '{branch name}')

# Modify arbitrary files and commit into the block.
pr_comet.commit '{commit message}' do
  file = File.read('path/to/file')
  file.sub!('hoge', 'fuga')
  File.write('path/to/file', file)
end

# You can also change files outer the block.
`bundle update`
pr_comet.commit '$ bundle update'

# Create a new pull request.
pr_comet.create!(
  title: 'New pull request',
  body: '{New pull request body}',
  labels: ['label 1', 'label 2'] # optional
)
```

## Rspec

### Testing

You can stub `PrComet` class for testing.
Add the following code to `spec/spec_helper`:

```ruby
require 'pr_comet/rspec'
```

Then you can use `#stub_pr_comet!`.
It makes `PrComet` class to stubbing and `PrComet.new` will return stubbed `PrComet` instance.
The stubbed `PrComet#commit` does not execute `$ git commit`, but it executes given block code.

```ruby
def create_pr
  pr_comet = PrComet.new(base: 'master', branch: 'any-branch') # stubbed.
  pr_comet.commit 'Hello world.' do # stubbed.
    File.write('path/to/file.txt', 'Hello world.') # not stubbed.
  end
  pr_comet.create!(title: 'New pull request') # stubbed.
end

stub_pr_comet!
allow(File).to receive(:write)
create_pr
expect(File).to have_received(:write).with('path/to/file.txt', 'Hello world.')
```

If you want to test about `PrComet`, you can use `#stub_pr_comet!` return value.
It returns any instance of `PrComet`.

```ruby
def create_pr
  pr_comet = PrComet.new(base: 'master', branch: 'any-branch')
  pr_comet.commit 'commit message' do
    # ...
  end
  pr_comet.create!(title: 'New pull request')
end

pr_comet = stub_pr_comet!
create_pr
expect(PrComet).to have_received(:new).with(base: 'master', branch: 'any-branch')
expect(pr_comet).to have_received(:commit).with('commit message')
expect(pr_comet).to have_received(:create!).with(title: 'New pull request')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pr_comet. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PrComet project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pr_comet/blob/master/CODE_OF_CONDUCT.md).
