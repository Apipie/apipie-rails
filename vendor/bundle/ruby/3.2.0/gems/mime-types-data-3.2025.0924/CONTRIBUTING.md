# Contributing

Contribution to mime-types-data is encouraged in any form: a bug report, new
MIME type definitions, or additional code to help manage the MIME types. There
are a few DOs and DON'Ts for contributions.

- DO:

  - Keep the coding style that already exists for any updated Ruby code (support
    or otherwise). I use [Standard Ruby][standardrb] for linting and formatting.

  - Use thoughtfully-named topic branches for contributions. Rebase your commits
    into logical chunks as necessary.

  - Use [quality commit messages][qcm].

  - Add your name or GitHub handle to `CONTRIBUTORS.md` and a record in the
    `CHANGELOG.md` as a separate commit from your main change. (Follow the style
    in the `CHANGELOG.md` and provide a link to your PR.)

- DO NOT:

  - Modify `VERSION` in `lib/mime/types/data.rb`. When your patch is accepted
    and a release is made, the version will be updated at that point. Most
    likely, once merged, your release will be rolled into the next automatic
    release.

  - Modify `mime-types-data.gemspec`; it is a generated file. (You _may_ use
    `rake gemspec` to regenerate it if your change involves metadata related to
    gem itself).

  - Modify the `Gemfile`.

  - Modify any files in `data/`. Any changes to be captured here will be
    automatically updated on the next release.

Although mime-types-data was extracted from the [Ruby mime-types][rmt] gem and
the support files are written in Ruby, the _target_ of mime-types-data is any
implementation that wishes to use the data as a MIME types registry, so I am
particularly interested in tools that will create a mime-types-data package for
other languages.

## Adding or Modifying MIME Types

The Ruby mime-types gem loads its data from files encoded in the `data`
directory in this gem by loading `mime-types-data` and reading
MIME::Types::Data::PATH. These files are compiled files from the collection of
data in the `types` directory.

> [!WARNING]
>
> Pull requests that include changes to files in `data/` will require amendment
> to revert these files.

New or modified MIME types should be edited in the appropriate YAML file under
`types`. The format is as shown below for the `application/xml` MIME type in
`types/application.yml`.

```yaml
- !ruby/object:MIME::Type
  content-type: application/xml
  encoding: 8bit
  extensions:
    - xml
    - xsl
  references:
    - IANA
    - RFC3023
  xrefs:
    rfc:
      - rfc3023
  registered: true
```

There are other fields that can be added, matching the fields discussed in the
documentation for MIME::Type. Pull requests for MIME types should just contain
the changes to the YAML files for the new or modified MIME types; I will convert
the YAML files to JSON prior to a new release. I would rather not have to verify
that the JSON matches the YAML changes, which is why it is not necessary to
convert for the pull request.

If you are making a change for a private fork, use `rake convert:yaml:json` to
convert the YAML to JSON, or `rake convert:yaml:columnar` to convert it to the
new columnar format.

### Updating Types from the IANA or Apache Lists

If you are maintaining a private fork and wish to update your copy of the MIME
types registry used by this gem, you can do this with the rake tasks:

```sh
$ rake mime:iana
$ rake mime:apache
```

#### A Note on Provisional Types

Provisionally registered types from IANA are contained in the `types/*.yaml`
files. Per IANA,

> This registry, unlike some other provisional IANA registries, is only for
> temporary use. Entries in this registry are either finalized and moved to the
> main media types registry or are abandoned and deleted. Entries in this
> registry are suitable for use for development and test purposes only.

Provisional types are rewritten when updated, so pull requests to manually
customize provisional types (such as with extensions) are considered lower
priority. It is recommended that any updates required to the data be performed
in your application if you require provisional types.

## The Release Process

The release process is almost completely automated, where upstream MIME types
will be updated weekly (on Tuesdays) and be presented in a reviewable pull
request. Once merged, the release will be automatically published to RubyGems.

With the addition of [trusted publishing][tp], there should no longer be a need
for manual releases outside of the update cycle. Pull requests merged between
cycles will be released on the next cycle.

If it becomes necessary to perform a manual release, IANA updates should be
performed manually.

1. Review any outstanding issues or pull requests to see if anything needs to be
   addressed. This is necessary because there is no automated source for
   extensions for the thousands of MIME entries. (Suggestions and/or pull
   requests for same would be deeply appreciated.)
2. `bundle install`
3. Review the changes to make sure that the changes are sane. The IANA data
   source changes from time to time, resulting in big changes or even a broken
   step 4. (The most recent change was the addition of the `font/*` top-level
   category.)
4. Write up the changes in `CHANGELOG.md`. If any PRs have been merged, these
   should be noted specifically and contributions should be added in
   `Contributing.md`.
5. Ensure that the `VERSION` in `lib/mime/types/data.rb` is updated with the
   current date UTC.
6. Run `rake gemspec` to ensure that `mime-types.gemspec` has been updated.
7. Commit the changes and push to GitHub. The automated trusted publishing
   workflow will pick up the changes.

This list is based on issue [#18][issue-18].

[hoe]: https://github.com/seattlerb/hoe
[issue-18]: https://github.com/mime-types/mime-types-data/issues/18
[qcm]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[release-gem]: https://github.com/rubygems/release-gem
[rmt]: https://github.com/mime-types/ruby-mime-types/
[standardrb]: https://github.com/standardrb/standard
[tp]: https://guides.rubygems.org/trusted-publishing/
