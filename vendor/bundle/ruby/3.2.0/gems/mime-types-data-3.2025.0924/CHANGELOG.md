# MIME Types Changes by Version

<!-- automatic-release -->

## 3.2025.0924 / 2025-09-24

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache Tika media registry][tika] as of the release date.


## NEXT / YYYY-MM—DD

- Removed the [Apache httpd media registry][httpd] from automatic updates.
  It is currently failing and no longer provides useful data compared to
  other sources. 

## 3.2025.0916 / 2025-09-16

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.


## 3.2025.0909 / 2025-09-09

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.


## 3.2025.0902 / 2025-09-02

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.


## 3.2025.0826 / 2025-08-26

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.


## 3.2025.0819 / 2025-08-19

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.


## 3.2025.0812 / 2025-08-12

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.


## 3.2025.0805 / 2025-08-05

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.


## 3.2025.0729 / 2025-07-29

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the [Apache httpd media registry][httpd],
  and the [Apache Tika media registry][tika] as of the release date.



- Remove `.doc` from `text/plain`: The use of `.doc` for `text/plain` documents
  is mostly a holdover from VAX VMS where the default wasn't `.txt` but `.doc`.
  The world now thinks that `.doc` mostly means `application/msword` even though
  that format is obsolete by almost twenty years. Closes
  [ruby-mime-types#224][ruby-mime-types#224] with [#191][pull-191].

- Handle promoted and withdrawn provisional IANA media types. Closes
  [#54][issue-54] with [#192][pull-192].

  The logic is three relatively simple phases:

  1. When loading an existing registry grouping (such as
     `types/application.yaml`), we mark any type that is `provisional` as
     `obsolete`. This indicates that we consider any provisional type as
     potentially withdrawn (and therefore obsolete).
  2. When processing existing regular types, we clear both `provisional` and
     `obsolete` flags so that a type promoted from provisional is now a regular
     registry entry.
  3. After merging the current list of registry entries, we _clear_
     `provisional` if the type is marked both `provisional` and `obsolete`,
     indicating that the provisional type has been withdrawn.

  These heuristics match several types which have been promoted and withdrawn
  since the handling of provisional types was improved with [#53][pull-53].

## 3.2025.0722 / 2025-07-22

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0715 / 2025-07-15

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0708 / 2025-07-08

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0701 / 2025-07-01

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0624 / 2025-06-24

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0617 / 2025-06-17

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0610 / 2025-06-10

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0603 / 2025-06-03

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0527 / 2025-05-27

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0520 / 2025-05-20

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0514 / 2025-05-14

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional], the
  [Apache httpd media registry][httpd], and the
  [Apache Tika media registry][tika] as of the release date.

## 3.2025.0507 / 2025-05-07

- Added new data for pre-computed priority sorting. This new data requires Ruby
  mime-types 3.7.0 or later to manage data but is ignored by older versions of
  mime-types.

- Added a parser for the [Apache Tika media registry][tika] to enrich the media
  definitions, mostly by adding new patterns for media type extensions. This
  parser:

  1. Parses the current `tika-mimetypes.xml` from the main branch of
     [Tika][tika] on GitHub.

  2. Skips over any `mime-type` record that has attributes. That is, any record
     which looks like `media/subtype;format=foo` or `media/subtype;version=2`
     will be skipped. Support for attributes does not currently exist in the
     mime-types library.

  3. Extracts the `glob` entries for use in the `extensions` field. Globs that
     use `*` in the middle of a filename are excluded, because that's now how
     the Ruby MIME::Types field works (I could add a new `glob` field, but that
     will take a bit more work).

  4. Updates the `extensions` field for any existing MIME::Type or creates new
     unregistered (not defined in IANA) types for new ones.

- Updated the history body to reflect the new data source for updates.

- Some details were removed from older CHANGELOG entries relating to updated
  MIME types from more or less automated processes.

## 3.2025.0506 / 2025-05-06

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0429 / 2025-04-29

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0422 / 2025-04-22

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0408 / 2025-04-08

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0402 / 2025-04-02

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0325 / 2025-03-25

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0318 / 2025-03-18

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0304 / 2025-03-04

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2025.0220 / 2025-02-20

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Added [trusted publishing][tp] for fully automated releases. Developed by
  Samuel Giddins in [#109][pull-109], merged manually with some updates.

## 3.2025.0204 / 2025-02-04

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Added the Changelog URL to the README so that RubyGems.org is updated with the
  `changelog_uri` on release. Contributed by Mark Young in [#96][pull-96].

- Fixed an issue with automated releases that added thousands of files because
  `vendor/` was no longer ignored.

- Fixed the automated release builder process to handle the case when the
  `automatic-release` tag is followed by a `## NEXT / YYYY-MM-DD` header so that
  changes merged normally are picked up on automatic releases. [#98][pull-98]

## 3.2025.0107 / 2025-01-07

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Restructured documentation for how I prefer to manage Hoe projects now.

- Reworked the Rakefile because all data updates are now managed by GitHub
  Actions and should not be managed manually any longer.

  - `rake release:prepare` now does the same work as `rake release:gha`, but
    does not commit or create a pull request.

  - `rake convert` no longer has any subtasks.

  - `rake update` has been removed with no replacement.

- Updated `.hoerc` to properly exclude `support/` and `types/` from the
  manifest.

## 3.2024.1203 / 2024-12-03

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.1105 / 2024-11-05

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.1001 / 2024-10-01

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.0903 / 2024-09-03

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.0820 / 2024-08-20

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Added `.jxl` extension for `image/jxl`. Contributed by Shane Eskritt in
  [#81][pull-81].

## 3.2024.0806 / 2024-08-06

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.0702 / 2024-07-02

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

  - This update adds a new `haptics/` group with three media types defined.

- Moved extensions from `audio/x-aac` to `audio/aac` and mark `audio/x-aac` as
  obsolete. Based on [#77][pull-77] by Samuel Williams.

  - Made the same changes for `audio/flac` and `audio/matroska`.

## 3.2024.0604 / 2024-06-04

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Internal changes:

  - Update to latest version of Rubygems for testing.

  - Remove restriction on Pysch version as that does not work well with current
    Rubies.

  - Fix a bug with the history generation on automatic updates.

## 3.2024.0507 / 2024-05-07

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.0402 / 2024-04-02

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.0305 / 2024-03-05

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.0206 / 2024-02-06

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2024.0102 / 2024-01-02

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2023.1205 / 2023-12-05

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2023.1107 / 2023-11-07

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2023.1003 / 2023-10-03

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2023.0905 / 2023-09-05

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2023.0808 / 2023-08-08

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2023.0218.1 / 2023-02-18

- When this data library was created in 2015, I made the decision based on
  information available to deprecate `text/javascript` in favour of
  `application/javascript`. Since the previous update (2022-01-05), IANA has
  officially deprecated `application/javascript` in favour of `text/javascript`.
  Samuel Williams discovered this in [#55][issue-55] by noting that all `js`
  types were marked obsolete in version 3.2023.0218.

  A hot fix has been applied to resolve this. However, note that
  `application/javascript` will not be returned by default, only
  `text/javascript`.

## 3.2023.0218 / 2023-02-18

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Mohammed Gad added the `jfif` file extension for `image/jpeg` text format.
  [#52][pull-52]

- Reworked the loading of IANA provisional media registries to merge them into
  the top-level media-type registries instead of a standalone registry file.
  [#53][pull-53] originally identified by Chris Salzberg in [#50][pull-50].

  It is worth noting that this is an _imperfect_ solution as if a media type is
  provisionally registered and withdrawn, it will linger in the registry with no
  clean way of identifying them at the moment. See [#54][issue-54].

  This release also fixes [ruby-mime-types#163][ruby-mime-types#163], where logs
  show "Type `application/netcdf` is already registered as a variant of
  `application/netcdf`".

## 3.2022.0105 / 2022-01-05

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Fixed an incorrect definition of `image/bmp`, which had been marked obsolete
  and later registered. Fixed [#48][issue-48], found by William T. Nelson.

## 3.2021.1115 / 2021-11-15

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Added conversion utilities that support the `mini_mime` data format. These
  have been ported from the [mini\_mime][mini_mime] repository. [#47][pull-47]

- Added IANA provisional media registries. Added some notes to CONTRIBUTING
  about the transient nature of the provisional registration data. This was
  triggered in part by a pull request by Jon Sneyers. Thanks! [#45][pull-45],
  [#43][pull-43]

## 3.2021.0901 / 2021-09-01

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Added file extension for `WebVTT` text format. [#46][pull-46]

## 3.2021.0704 / 2021-07-04

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

## 3.2021.0225 / 2021-02-25

- Updated registry entries from the IANA [media registry][registry] and
  [provisional media registry][provisional] and the
  [Apache httpd media registry][httpd] as of the release date.

- Added file extension for `AVIF` video format. [#40][pull-40]

## 3.2021.0212 / 2021-02-12

- Updated the IANA media registry entries as of release date.

- Added a new rake task (`release:automatic`) that downloads and converts the
  data from Apache httpd and IANA registries; if there are changes detected, it
  updates the release version, changelog, manifest, and `gemspec` and commits
  the changes to git.

## 3.2020.1104 / 2020-11-04

- Updated the IANA media registry entries as of release date.

- Added `application/x-zip-compressed`. [#36][pull-36]

- Updated the contributing guide to include information about the release
  process as described in [#18][issue-18]

- Corrected a misspelling of Yoran Brondsema's name. Sorry, Yoran.
  [#35][pull-35]

## 3.2020.0512 / 2020-05-12

- Updated the IANA media registry entries as of release date.

- Added file extensions for `HEIC` image types. [#34][pull-34]

## 3.2020.0425 / 2020-04-25

- Updated the IANA media registry entries as of release date.

- Added several RAW image types based on data from GNOME RAW Thumbnailer.
  [#33][pull-33] fixing [#32][issue-32]

- Added `audio/wav`. [#31][pull-31]

- Added a type for Smarttech notebook files. [#30][pull-30]

- Added an alias for audio/m4a files. [#29][pull-29]

- Added application/x-ms-dos-executable. [#28][pull-28]

## 3.2019.1009 / 2019-10-09

- Updated the IANA media registry entries as of release date.

- Reordered the `.ai` extension so that it is not the preferred extension for
  `application/pdf` [#24][pull-24]

## 3.2019.0904 / 2019-09-04

- Updated the IANA media registry entries as of release date.

- Moved the `.ai` extension from `application/postscript` to `application/pdf`.
  [#23][pull-23] fixing [#22][issue-22]

## 3.2019.0331 / 2019-03-31

- Updated the IANA media registry entries as of release date.

- Added support for `application/wasm` with extension `.wasm`. [#21][pull-21]

- Fixed `application/ecmascript` extensions. [#20][pull-20]

## 3.2018.0812 / 2018-08-12

- Added `.xsd` extension to `text/xml`. [pull-10][pull-10]

- Added `.js` and `.mjs` extensions to `text/ecmascript` and `text/javascript`.
  [#11][pull-11]

- Added `.ipa` extension to `application/octet-stream`. [#12][pull-12]

- Moved extensions `.markdown` and `.md` and added `.mkd` extension to
  `text/markdown`. [#13][pull-13]

- Because of a bug found with mime-types 3 before 3.2.1, this version requires
  mime-types 3.2 or later to manage data.

- Updated the IANA media registry entries as of release date. The biggest major
  change here is the addition of the `font/` top-level media type.

- MIME type changes not introduced by pull requests will no longer be
  individually tracked.

- Clarified that the YAML editable format is not shipped with the Ruby gem for
  size considerations.

## 3.2016.0521 / 2016-05-21

- Updated the known extension list for `application/octet-stream` and
  `application/pgp-encrypted` to include `gpg` as an extension. Fixes
  [#3][pull-3] by Tao Guo ([@taonic](https://github.com/taonic)).

- Updated the IANA media registry entries as of release date.

- This version requires mime-types 3.1 or later to manage data because of an
  issue with JSON data encoding for the `xrefs` field.

## 3.2016.0221 / 2016-02-21

- Updated the known extensions list for audio/mp4.

- Updated to [Contributor Covenant 1.4][code of conduct].

- Shift the support code in this repository to be developed with Ruby 2.3. This
  involves:

  - Adding `frozen_string_literal: true` to all Ruby files.
  - Applied some recommended readability and performance suggestions from
    Rubocop. Ignored some style recommendations, too.
  - Replaced some cases of `foo.bar rescue nil` with `foo&.bar`.

## 3.2015.1120 / 2015-11-20

- Extracted from [ruby-mime-types][rmt].
- Added a [Code of Conduct][Code of Conduct].
- The versioning has changed to be semantic on format plus date in two parts.

  - All registry formats have been updated to remove deprecated data.
  - The columnar format has been updated to store three boolean flags in a
    single flags file.

- Updated the conversion and management utilities to work with ruby-mime-types
  3.x.

- Updated the IANA media registry entries as of release date.

## 2.6.2 / 2015-09-13

- Updated the IANA media registry entries as of release date.

## 2.6 / 2015-05-25

- Steven Michael Thomas
  ([@stevenmichaelthomas](https://github.com/stevenmichaelthomas)) added `woff2`
  as an extension to `application/font-woff`,
  [ruby-mime-types#99][ruby-mime-types#99].
- Updated the IANA media registry entries as of release date.

## 2.5 / 2015-04-25

- Updated the IANA media registry entries as of release date.

- Andy Brody ([@ab](https://github.com/ab)) fixed a pair of embarrassing typos
  in `text/csv` and `text/tab-separated-values`,
  [ruby-mime-types#89](https://github.com/mime-types/ruby-mime-types/pull/89).

- Aggelos Avgerinos ([@eavgerinos](https://github.com/eavgerinos)) added the
  unregistered MIME type `image/x-ms-bmp` with the extension `bmp`,
  [ruby-mime-types#90](https://github.com/mime-types/ruby-mime-types/pull/90).

## 2.4.2 / 2014-10-15

- Added `application/vnd.ms-outlook` as an unregistered MIME type with the
  extension `msg`. Provided by [@keerthisiv](https://github.com/keerthisiv) in
  [ruby-mime-types#72](https://github.com/mime-types/ruby-mime-types/pull/72).

## 2.4.1 / 2014-10-07

- Changed the sort order of many of the extensions to restore behaviour from
  mime-types 1.25.1.
- Added `friendly` MIME::Type descriptions where known.
- Added `reg`, `ps1`, and `vbs` extensions to `application/x-msdos-program` and
  `application/x-msdownload`.
- Updated the IANA media registry entries as of release date.

## 2.3 / 2014-05-23

- Updated the IANA media registry entries as of release date.

## 2.2 / 2014-03-14

- Added `.sj` to `application/javascript` as provided by Brandon Galbraith
  ([@brandongalbraith](https://github.com/brandongalbraith)) in
  [ruby-mime-types#58](https://github.com/mime-types/ruby-mime-types/pull/58).

- Marked `application/excel` and `application/x-excel` as obsolete in favour of
  `application/vnd.ms-excel` per
  [ruby-mime-types#60](https://github.com/mime-types/ruby-mime-types/pull/60).

- Merged duplicate MIME types into the registered MIME type. The only difference
  between the MIME types was capitalization; the MIME type registry is
  case-preserving.

- Updated the IANA media registry entries as of release date.

## 2.1 / 2014-01-25

- The IANA media type registry format changed, resulting in updates to most of
  the 1,427 registered MIME types.
  - Many registered MIME types have had some metadata updates due to the change
    in the IANA registry format.
    - MIME types having a publicly available registry application now include a
      link to that file in references.
  - Added `xrefs` data as discovered (see the API changes noted above).

- The Apache httpd mime types configuration has been added to track additional
  common but unregistered MIME types and known extensions for those MIME types.
  This has affected many of the available MIME types.

- Merged the non-standard VMS platform `text/plain` with the standard
  `text/plain`.

[code of conduct]: CODE_OF_CONDUCT.md
[httpd]: https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
[issue-18]: https://github.com/mime-types/mime-types-data/issues/18
[issue-22]: https://github.com/mime-types/mime-types-data/issues/22
[issue-32]: https://github.com/mime-types/mime-types-data/issues/32
[issue-48]: https://github.com/mime-types/mime-types-data/issues/48
[issue-54]: https://github.com/mime-types/mime-types-data/issues/54
[issue-55]: https://github.com/mime-types/mime-types-data/issues/55
[mini_mime]: https://github.com/discourse/mini_mime/issues/41
[provisional]: https://www.iana.org/assignments/provisional-standard-media-types/provisional-standard-media-types.xml
[pull-109]: https://github.com/mime-types/mime-types-data/pull/109
[pull-10]: https://github.com/mime-types/mime-types-data/pull/10
[pull-11]: https://github.com/mime-types/mime-types-data/pull/11
[pull-12]: https://github.com/mime-types/mime-types-data/pull/12
[pull-13]: https://github.com/mime-types/mime-types-data/pull/13
[pull-191]: https://github.com/mime-types/mime-types-data/pull/191
[pull-192]: https://github.com/mime-types/mime-types-data/pull/192
[pull-20]: https://github.com/mime-types/mime-types-data/pull/20
[pull-21]: https://github.com/mime-types/mime-types-data/pull/21
[pull-23]: https://github.com/mime-types/mime-types-data/pull/23
[pull-24]: https://github.com/mime-types/mime-types-data/pull/24
[pull-28]: https://github.com/mime-types/mime-types-data/pull/28
[pull-29]: https://github.com/mime-types/mime-types-data/pull/29
[pull-30]: https://github.com/mime-types/mime-types-data/pull/30
[pull-31]: https://github.com/mime-types/mime-types-data/pull/31
[pull-33]: https://github.com/mime-types/mime-types-data/pull/33
[pull-34]: https://github.com/mime-types/mime-types-data/pull/34
[pull-35]: https://github.com/mime-types/mime-types-data/pull/35
[pull-36]: https://github.com/mime-types/mime-types-data/pull/36
[pull-3]: https://github.com/mime-types/mime-types-data/pull/3
[pull-40]: https://github.com/mime-types/mime-types-data/pull/40
[pull-43]: https://github.com/mime-types/mime-types-data/pull/43
[pull-45]: https://github.com/mime-types/mime-types-data/pull/45
[pull-46]: https://github.com/mime-types/mime-types-data/pull/46
[pull-47]: https://github.com/mime-types/mime-types-data/pull/47
[pull-50]: https://github.com/mime-types/mime-types-data/pull/50
[pull-52]: https://github.com/mime-types/mime-types-data/pull/52
[pull-53]: https://github.com/mime-types/mime-types-data/pull/53
[pull-77]: https://github.com/mime-types/mime-types-data/pull/77
[pull-81]: https://github.com/mime-types/mime-types-data/pull/81
[pull-96]: https://github.com/mime-types/mime-types-data/pull/96
[pull-98]: https://github.com/mime-types/mime-types-data/pull/98
[registry]: https://www.iana.org/assignments/media-types/media-types.xml
[rmt]: https://github.com/mime-types/ruby-mime-types
[ruby-mime-types#163]: https://github.com/mime-types/ruby-mime-types/issues/163
[ruby-mime-types#224]: https://github.com/mime-types/ruby-mime-types/pull/224
[ruby-mime-types#99]: https://github.com/mime-types/ruby-mime-types/pull/99
[tika]: https://github.com/apache/tika/blob/main/tika-core/src/main/resources/org/apache/tika/mime/tika-mimetypes.xml
[tp]: https://guides.rubygems.org/trusted-publishing/
