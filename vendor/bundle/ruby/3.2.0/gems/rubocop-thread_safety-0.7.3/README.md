# RuboCop::ThreadSafety

Thread-safety analysis for your projects, as an extension to
[RuboCop](https://github.com/rubocop/rubocop).

## Installation and Usage

### Installation into an application

Add this line to your application's Gemfile (using `require: false` as it's a standalone tool):

```ruby
gem 'rubocop-thread_safety', require: false
```

Install it with Bundler by invoking:

    $ bundle

Add this line to your application's `.rubocop.yml`:

    plugins: rubocop-thread_safety

Now you can run `rubocop` and it will automatically load the RuboCop
Thread-Safety cops together with the standard cops.

> [!NOTE]
> The plugin system is supported in RuboCop 1.72+. In earlier versions, use `require` instead of `plugins`.

### Scanning an application without adding it to the Gemfile

Install the gem:

    $ gem install rubocop-thread_safety

Scan the application for just thread-safety issues:

    $ rubocop --plugin rubocop-thread_safety --only ThreadSafety,Style/GlobalVars,Style/ClassVars,Style/MutableConstant

### Configuration

There are some added [configuration options](https://github.com/rubocop/rubocop-thread_safety/blob/master/config/default.yml) that can be tweaked to modify the behaviour of these thread-safety cops.

### Correcting code for thread-safety

There are a few ways to improve thread-safety that stem around avoiding
unsynchronized mutation of state that is shared between multiple threads.

State shared between threads may take various forms, including:

* Class variables (`@@name`). Note: these affect child classes too.
* Class instance variables (`@name` in class context or class methods)
* Constants (`NAME`). Ruby will warn if a constant is re-assigned to a new value but will allow it. Mutable objects can still be mutated (e.g. push to an array) even if they are assigned to a constant.
* Globals (`$name`), with the possible exception of some special globals provided by ruby that are documented as thread-local like regular expression results.
* Variables in the scope of created threads (where `Thread.new` is called).

Improvements that would make shared state thread-safe include:

* `freeze` objects to protect against mutation. Note: `freeze` is shallow, i.e. freezing an array will not also freeze its elements.
* Use data structures or concurrency abstractions from [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby), e.g. `Concurrent::Map`
* Use a `Mutex` or similar to `synchronize` access.
* Use [`ActiveSupport::CurrentAttributes`](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html)
* Use [`RequestStore`](https://github.com/steveklabnik/request_store)
* Use `Thread.current[:name]`

Certain system calls, such as `chdir`, affect the entire process. To avoid potential thread-safety issues, it's preferable to use (if possible) the `chdir` option in methods like `Kernel.system` and `IO.popen` rather than relying on `Dir.chdir`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubocop/rubocop-thread_safety.

## Copyright

Portions Copyright (c) 2016-2023 Michael Gee and [contributors](https://github.com/rubocop/rubocop-thread_safety/graphs/contributors).
Portions Copyright (c) 2016-2023 CoverMyMeds.

See [LICENSE.txt](LICENSE.txt) for further details.
