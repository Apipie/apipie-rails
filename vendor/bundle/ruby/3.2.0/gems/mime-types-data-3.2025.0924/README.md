# mime-types-data

- home :: https://github.com/mime-types/mime-types-data/
- issues :: https://github.com/mime-types/mime-types-data/issues
- code :: https://github.com/mime-types/mime-types-data/
- changelog ::
  https://github.com/mime-types/mime-types-data/blob/main/CHANGELOG.md

## Description

mime-types-data provides a registry for information about MIME media type
definitions. It can be used with the Ruby mime-types library or other software
to determine defined filename extensions for MIME types, or to use filename
extensions to look up the likely MIME type definitions.

### About MIME Media Types

MIME media types are used in MIME-compliant communications, as in e-mail or HTTP
traffic, to indicate the type of content which is transmitted. The registry
provided in mime-types-data contains detailed information about MIME entities.
There are many types defined by RFCs and vendors, so the list is long but
invariably; don't hesitate to offer additional type definitions for
consideration. MIME type definitions found in mime-types are from RFCs, W3C
recommendations, the [IANA Media Types registry][registry], the
[Apache httpd registry][httpd], the [Apache Tika media registry][tika] and user
contributions. It conforms to RFCs 2045 and 2231.

### Data Formats Supported in this Registry

This registry contains the MIME media types in four formats:

- A YAML format matching the Ruby mime-types library objects (MIME::Type). This
  is the primary user-editable format for developers. It is _not_ shipped with
  the gem due to size considerations.
- A JSON format converted from the YAML format. Prior to Ruby mime-types 3.0,
  this was the main consumption format and is still recommended for any
  implementation that does not wish to implement the columnar format, which has
  a significant implementation effort cost.
- An encoded text format splitting the data for each MIME type across multiple
  files. This columnar data format reduces the minimal data load substantially,
  resulting in a performance improvement at the cost of more complex code for
  loading the data on-demand. This is the default format for Ruby mime-types
  3.0.
- An encoded text format for use with [`mini_mime`][minimime]. This can be
  enabled with:

  ```ruby
  MiniMime::Configuration.ext_db_path =
    File.join(MIME::Types::Data::PATH, "ext_mime.db")
  MiniMime::Configuration.content_type_db_path =
    File.join(MIME::Types::Data::PATH, "content_type_mime.db")
  ```

## mime-types-data Modified Semantic Versioning

mime-types-data uses a [Semantic Versioning][semver] scheme heavily modified
with [Calendar Versioning][calver] aspects to indicate that the data formats
compatibility based on a `SCHEMA` version and the date of the data update:
`SCHEMA.YEAR.MONTHDAY`.

1. If an incompatible data format change is made to any of the supported
   formats, `SCHEMA` will be incremented. The current `SCHEMA` is 3, supporting
   the YAML, JSON, columnar, and mini-mime formats required for Ruby mime-types
   3.0.

2. When the data is updated, the `YEAR.MONTHDAY` combination will be updated. An
   update on the last day of October 2025 would be written as `2025.1031`,
   resulting in the full version of `3.2025.1031`.

3. If multiple versions of the data need to be released on the same day due to
   error, there will be an additional `REVISION` field incremented on the end of
   the version. Thus, if three revisions need to be published on October 31st,
   2015, the last release would be `3.2015.1031.2` (remember that the first
   release has an implied `0`.)

[registry]: https://www.iana.org/assignments/media-types/media-types.xml
[semver]: http://semver.org/
[minimime]: https://github.com/discourse/mini_mime
[httpd]: https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
[tika]: https://github.com/apache/tika/blob/main/tika-core/src/main/resources/org/apache/tika/mime/tika-mimetypes.xml
[calver]: https://calver.org
