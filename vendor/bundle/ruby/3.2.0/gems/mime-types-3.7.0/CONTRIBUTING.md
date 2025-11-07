# Contributing

Contribution to mime-types is encouraged in any form: a bug report, a feature
request, or code contributions. There are a few DOs and DON'Ts for
contributions.

- DO:

  - Keep the coding style that already exists for any updated Ruby code (support
    or otherwise). I use [Standard Ruby][standardrb] for linting and formatting.

  - Use thoughtfully-named topic branches for contributions. Rebase your commits
    into logical chunks as necessary.

  - Use [quality commit messages][qcm].

  - Add your name or GitHub handle to `CONTRIBUTORS.md` and a record in the
    `CHANGELOG.md` as a separate commit from your main change. (Follow the style
    in the `CHANGELOG.md` and provide a link to your PR.)

  - Add or update tests as appropriate for your change. The test suite is
    written with [minitest][minitest].

  - Add or update documentation as appropriate for your change. The
    documentation is RDoc; mime-types does not use extensions that may be
    present in alternative documentation generators.

- DO NOT:

  - Modify `VERSION` in `lib/mime/types/version.rb`. When your patch is accepted
    and a release is made, the version will be updated at that point.

  - Modify `mime-types.gemspec`; it is a generated file. (You _may_ use
    `rake gemspec` to regenerate it if your change involves metadata related to
    gem itself).

  - Modify the `Gemfile`.

## Adding or Modifying MIME Types

The mime-types registry is managed in [mime-types-data][mtd].

## Test Dependencies

mime-types uses Ryan Davis's [Hoe][Hoe] to manage the release process, and it
adds a number of rake tasks. You will mostly be interested in `rake`, which runs
the tests the same way that `rake test` will do.

To assist with the installation of the development dependencies for mime-types,
I have provided the simplest possible Gemfile pointing to the (generated)
`mime-types.gemspec` file. This will permit you to do `bundle install` to get
the development dependencies.

You can run tests with code coverage analysis by running `rake coverage`.

## Benchmarks

mime-types offers several benchmark tasks to measure different measures of
performance.

There is a repeated load test, measuring how long it takes to start and load
mime-types with its full registry. By default, it runs fifty loops and uses the
built-in benchmark library:

- `rake benchmark:load`

There are two loaded object count benchmarks (for normal and columnar loads).
These use `ObjectSpace.count_objects`.

- `rake benchmark:objects`
- `rake benchmark:objects:columnar`

## Workflow

Here's the most direct way to get your work merged into the project:

- Fork the project.
- Clone down your fork
  (`git clone git://github.com/<username>/ruby-mime-types.git`).
- Create a topic branch to contain your change
  (`git checkout -b my_awesome_feature`).
- Hack away, add tests. Not necessarily in that order.
- Make sure everything still passes by running `rake`.
- If necessary, rebase your commits into logical chunks, without errors.
- Push the branch up (`git push origin my_awesome_feature`).
- Create a pull request against mime-types/ruby-mime-types and describe what
  your change does and the why you think it should be merged.

[hoe]: https://github.com/seattlerb/hoe
[minitest]: https://github.com/seattlerb/minitest
[mtd]: https://github.com/mime-types/mime-types-data
[qcm]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[standardrb]: https://github.com/standardrb/standard
