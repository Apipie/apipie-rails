# mime-types for Ruby

- home :: https://github.com/mime-types/ruby-mime-types/
- issues :: https://github.com/mime-types/ruby-mime-types/issues
- code :: https://github.com/mime-types/ruby-mime-types/
- rdoc :: http://rdoc.info/gems/mime-types/
- changelog ::
  https://github.com/mime-types/ruby-mime-types/blob/main/CHANGELOG.md
- continuous integration :: [![Build Status][ci-badge]][ci-workflow]
- test coverage :: [![Coverage][coveralls-badge]][coveralls]

## Description

The mime-types library provides a library and registry for information about
MIME content type definitions. It can be used to determine defined filename
extensions for MIME types, or to use filename extensions to look up the likely
MIME type definitions.

Version 3.0 is a major release that requires Ruby 2.0 compatibility and removes
deprecated functions. The columnar registry format introduced in 2.6 has been
made the primary format; the registry data has been extracted from this library
and put into [mime-types-data][data]. Additionally, mime-types is now licensed
exclusively under the MIT licence and there is a code of conduct in effect.
There are a number of other smaller changes described in the History file.

### About MIME Media Types

MIME content types are used in MIME-compliant communications, as in e-mail or
HTTP traffic, to indicate the type of content which is transmitted. The
mime-types library provides the ability for detailed information about MIME
entities (provided as an enumerable collection of MIME::Type objects) to be
determined and used. There are many types defined by RFCs and vendors, so the
list is long but by definition incomplete; don't hesitate to add additional type
definitions. MIME type definitions found in mime-types are from RFCs, W3C
recommendations, the [IANA Media Types registry][registry], and user
contributions. It conforms to RFCs 2045 and 2231.

### mime-types 3.x

Users are encouraged to upgrade to mime-types 3.x as soon as is practical.
mime-types 3.x requires Ruby 2.0 compatibility and a simpler licensing scheme.

## Synopsis

MIME types are used in MIME entities, as in email or HTTP traffic. It is useful
at times to have information available about MIME types (or, inversely, about
files). A MIME::Type stores the known information about one MIME type.

```ruby
require 'mime/types'

plaintext = MIME::Types['text/plain'] # => [ text/plain ]
text = plaintext.first
puts text.media_type            # => 'text'
puts text.sub_type              # => 'plain'

puts text.extensions.join(' ')  # => 'txt asc c cc h hh cpp hpp dat hlp'
puts text.preferred_extension   # => 'txt'
puts text.friendly              # => 'Text Document'
puts text.i18n_key              # => 'text.plain'

puts text.encoding              # => quoted-printable
puts text.default_encoding      # => quoted-printable
puts text.binary?               # => false
puts text.ascii?                # => true
puts text.obsolete?             # => false
puts text.registered?           # => true
puts text.provisional?          # => false
puts text.complete?             # => true

puts text                       # => 'text/plain'

puts text == 'text/plain'       # => true
puts 'text/plain' == text       # => true
puts text == 'text/x-plain'     # => false
puts 'text/x-plain' == text     # => false

puts MIME::Type.simplified('x-appl/x-zip') # => 'x-appl/x-zip'
puts MIME::Type.i18n_key('x-appl/x-zip') # => 'x-appl.x-zip'

puts text.like?('text/x-plain') # => true
puts text.like?(MIME::Type.new('x-text/x-plain')) # => true

puts text.xrefs.inspect # => { "rfc" => [ "rfc2046", "rfc3676", "rfc5147" ] }
puts text.xref_urls # => [ "http://www.iana.org/go/rfc2046",
                    #      "http://www.iana.org/go/rfc3676",
                    #      "http://www.iana.org/go/rfc5147" ]

xtext = MIME::Type.new('x-text/x-plain')
puts xtext.media_type # => 'text'
puts xtext.raw_media_type # => 'x-text'
puts xtext.sub_type # => 'plain'
puts xtext.raw_sub_type # => 'x-plain'
puts xtext.complete? # => false

puts MIME::Types.any? { |type| type.content_type == 'text/plain' } # => true
puts MIME::Types.all?(&:registered?) # => false

# Various string representations of MIME types
qcelp = MIME::Types['audio/QCELP'].first # => audio/QCELP
puts qcelp.content_type         # => 'audio/QCELP'
puts qcelp.simplified           # => 'audio/qcelp'

xwingz = MIME::Types['application/x-Wingz'].first # => application/x-Wingz
puts xwingz.content_type        # => 'application/x-Wingz'
puts xwingz.simplified          # => 'application/x-wingz'
```

### Columnar Store

mime-types uses as its primary registry storage format a columnar storage format
reducing the default memory footprint. This is done by selectively loading the
data on a per-attribute basis. When the registry is first loaded from the
columnar store, only the canonical MIME content type and known extensions and
the MIME type will be connected to its loading registry. When other data about
the type is required (including `preferred_extension`, `obsolete?`, and
`registered?`) that data is loaded from its own column file for all types in the
registry.

The load of any column data is performed with a Mutex to ensure that types are
updated safely in a multithreaded environment. Benchmarks show that while
columnar data loading is slower than the JSON store, it cuts the memory use by a
third over the JSON store.

If you prefer to load all the data at once, this can be specified in your
application Gemfile as:

```ruby
gem 'mime-types', require: 'mime/types/full'
```

Projects that do not use Bundler should `require` the same:

```ruby
require 'mime/types/full'
```

Libraries that use mime-types are discouraged from choosing the JSON store.

For applications and clients that used mime-types 2.6 when the columnar store
was introduced, the require used previously will still work through at least
[version 4][pull-96-comment] and possibly beyond; it is effectively an empty
operation. You are recommended to change your Gemfile as soon as is practical.

```ruby
require 'mime/types/columnar'
```

Note that MIME::Type::Columnar and MIME::Types::Columnar are considered private
variant implementations of MIME::Type and MIME::Types and the specific
implementation should not be relied upon by consumers of the mime-types library.
Instead, depend on the public implementations (MIME::Type and MIME::Types) only.

### Cached Storage

mime-types supports a cache of MIME types using `Marshal.dump`. The cache is
invalidated for each version of the mime-types-data gem so that data version
3.2015.1201 will not be reused with data version 3.2016.0101. If the environment
variable `RUBY_MIME_TYPES_CACHE` is set to a cache file, mime-types will attempt
to load the MIME type registry from the cache file. If it cannot, it will load
the types normally and then saves the registry to the cache file.

The caching works with both full stores and columnar stores. Only the data that
has been loaded prior to saving the cache will be stored.

## mime-types Modified Semantic Versioning

The mime-types library has one version number, but this single version number
tracks both API changes and registry data changes; this is not wholly compatible
with all aspects of [Semantic Versioning][semver]; removing a MIME type from the
registry _could_ be considered a breaking change under some interpretations of
semantic versioning (as lookups for that particular type would no longer work by
default).

mime-types itself uses a modified semantic versioning scheme. Given the version
`MAJOR.MINOR`:

1. If an incompatible API (code) change is made, the `MAJOR` version will be
   incremented and both `MINOR` and `PATCH` will be set to zero. Major version
   updates will also generally break Ruby version compatibility guarantees.

2. If an API (code) feature is added that does not break compatibility, the
   `MINOR` version will be incremented and `PATCH` will be set to zero.

3. If there is a bug fix to a feature added in the most recent `MAJOR.MINOR`
   release, the `PATCH` value will be incremented.

In practical terms, there will be fewer releases of mime-types focussing on
features because of the existence of the [mime-types-data][data] gem, and if
features are marked deprecated in the course of mime-types 3.x, they will not be
removed until mime-types 4.x or possibly later.

[pull-96-comment]: https://github.com/mime-types/ruby-mime-types/pull/96#issuecomment-100725400
[semver]: https://semver.org
[data]: https://github.com/mime-types/mime-types-data
[ci-badge]: https://github.com/mime-types/ruby-mime-types/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/mime-types/ruby-mime-types/actions/workflows/ci.yml
[coveralls-badge]: https://coveralls.io/repos/mime-types/ruby-mime-types/badge.svg?branch=main&service=github
[coveralls]: https://coveralls.io/github/mime-types/ruby-mime-types?branch=main
[registry]: https://www.iana.org/assignments/media-types/media-types.xhtml
