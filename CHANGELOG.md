 Changelog
===========

## [v1.4.0](https://github.com/Apipie/apipie-rails/tree/v1.4.0) (2024-05-30)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v1.3.0...v1.4.0)
* Add Ruby 3.3.0 to CI build matrix (#906) Masato Nakamura
* Fix rubocop CI (#910) (Masato Nakamura)
* Add metadata for rubygems.org and use https URLs (#909) (Masato Nakamura)
* Bump GHA actions/checkout to be on node20 by default (#911) (Masato Nakamura)
* Convert readme to markdown (#920) (Panos Dalitsouris)
* Fix typos, Found via `codespell` (#921) (Kian-Meng Ang)
* Bump ruby versions on test jobs (#927) (Masato Nakamura)
* Support for Ruby 3.4.0-preview1 (#929) (Masato Nakamura)
* Add "blank allowed" message to api doc (#926) (Peko)
* Custom headers responses (#924) (Panos Dalitsouris)

## [v1.3.0](https://github.com/Apipie/apipie-rails/tree/v1.3.0) (2023-12-19)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v1.2.3...v1.3.0)
* rubocop fixes ([#897](https://github.com/Apipie/apipie-rails/pull/897)) (Mathieu Jobin)
* Fix usage of deprecated Rack::File in Rack 3.0 ([#896](https://github.com/Apipie/apipie-rails/pull/896)) (James Dean Shepherd)
* add rails 7.1 to the build matrix ([#898](https://github.com/Apipie/apipie-rails/pull/898)) (Mathieu Jobin)
* super small typo fix ([#900](https://github.com/Apipie/apipie-rails/pull/900)) (Eric Pugh)
* support for property example ([#901](https://github.com/Apipie/apipie-rails/pull/901)) (Chien-Wei Huang (Michael))
* Use array items type from validator ([#904](https://github.com/Apipie/apipie-rails/pull/)) (Panos Dalitsouris)

## [v1.2.3](https://github.com/Apipie/apipie-rails/tree/v1.2.3) (2023-10-11)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v1.2.2...v1.2.3)
* Fix param: Consider default_value: nil as valid config ([#894](https://github.com/Apipie/apipie-rails/pull/894)) (davidwessman)

## [v1.2.2](https://github.com/Apipie/apipie-rails/tree/v1.2.2) (2023-07-18)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v1.2.1...v1.2.2)
* Fixed Swagger warnings for properties ([#892](https://github.com/Apipie/apipie-rails/pull/892)) (shev-vadim-net)
* Improved support for multipart/form-data example recording ([#891](https://github.com/Apipie/apipie-rails/pull/891)) (Butiri Cristian & hossenlopp)
* rubocop (1.54.2) fixes required with latest version ([#893](https://github.com/Apipie/apipie-rails/pull/893)) (Mathieu Jobin)

## [v1.2.1](https://github.com/Apipie/apipie-rails/tree/v1.2.1) (2023-06-09)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v1.2.0...v1.2.1)
* rspec: Fixes deprecated matcher ([#882](https://github.com/Apipie/apipie-rails/pull/882)) (David Wessman)
* Fix streaming bug ([#677](https://github.com/Apipie/apipie-rails/pull/677)) (Hunter Braun)
* Update README URLs based on HTTP redirects ([#448](https://github.com/Apipie/apipie-rails/pull/448)) (ReadmeCritic)
* Swagger: Adds option to skip default tags ([#881](https://github.com/Apipie/apipie-rails/pull/881)) (David Wessman)
* Parameter validation: Raises error for all missing ([#886](https://github.com/Apipie/apipie-rails/pull/886)) (David Wessman)

## [v1.2.0](https://github.com/Apipie/apipie-rails/tree/v1.2.0) (2023-06-03)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v1.1.0...v1.2.0)
* Allow resource_name to be inherited ([#872](https://github.com/Apipie/apipie-rails/pull/872)) (Eric Hankins)
* Fix cache rendering with namespaced resources ([#874](https://github.com/Apipie/apipie-rails/pull/874)) (Eric Hankins)
* Fix deprecated content_type on Rails >= 6 ([#879](https://github.com/Apipie/apipie-rails/pull/879)) (Eric Hankins)
* Fix typo in Collector ([#877](https://github.com/Apipie/apipie-rails/pull/877)) (Eric Hankins)
* Fix error climbing controller hierarchy ([#875](https://github.com/Apipie/apipie-rails/pull/875)) (Eric Hankins)
* Add Gemfile.tools for IDE usage ([#876](https://github.com/Apipie/apipie-rails/pull/876)) (Eric Hankins)
* Fix rubocop ([#883](https://github.com/Apipie/apipie-rails/pull/883)) (Mathieu Jobin)
* Performance/InefficientHashSearch-20230602233137 ([#884](https://github.com/Apipie/apipie-rails/pull/884)) (RuboCop challenger)
* Redo Github action script to not need individual gemfiles ([#885](https://github.com/Apipie/apipie-rails/pull/885)) (Mathieu Jobin)

## [v1.1.0](https://github.com/Apipie/apipie-rails/tree/v1.1.0) (2023-05-16)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v1.0.0...v1.1.0)
* Improve performance of route detection [#870](https://github.com/Apipie/apipie-rails/pull/870) (Eric Hankins)
* Fix startup crash due to typo [#869](https://github.com/Apipie/apipie-rails/pull/869) (Eric Hankins)
* Skip parse body for pdf responses [#871](https://github.com/Apipie/apipie-rails/pull/871) (Juan Gomez)
* add missing 'returns' translation [#868](https://github.com/Apipie/apipie-rails/pull/868) (Anthony Robertson)

## [v1.0.0](https://github.com/Apipie/apipie-rails/tree/v1.0.0) (2023-04-26)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.9.4...v1.0.0)
* Refactor Swagger generator [#816](https://github.com/Apipie/apipie-rails/pull/816) (Panos Dalitsouris)
* Take into account validator options for `required` ParamDescription [#863](https://github.com/Apipie/apipie-rails/pull/863) (Panos Dalitsouris)
* Replace `get_resource_name` with `get_resource_id` [#864](https://github.com/Apipie/apipie-rails/pull/864) (Panos Dalitsouris)
* Namespace swagger configuration [#862](https://github.com/Apipie/apipie-rails/pull/862) (Panos Dalitsouris)
* Allow boolean array `[true, false]` to be a valid argument for BooleanValidator [#848](https://github.com/Apipie/apipie-rails/pull/848) (Panos Dalitsouris)
* Fix swagger warnings [#865](https://github.com/Apipie/apipie-rails/pull/865) (Panos Dalitsouris)
* Update README - Adds the new Integer option you added recently to the documentation here. [#866](https://github.com/Apipie/apipie-rails/pull/866) (Jeremy Lupoli)
* [Rubocop] More Rubocop Auto corrections [#859](https://github.com/Apipie/apipie-rails/pull/859)

## [v0.9.4](https://github.com/Apipie/apipie-rails/tree/v0.9.4) (2023-04-11)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.9.3...v0.9.4)
* [Fix] Separate nested resource name [#855](https://github.com/Apipie/apipie-rails/pull/855), [#455](https://github.com/Apipie/apipie-rails/issues/455) (Panos Dalitsouris)
* [Rubocop] Disable a few Rubocop Rules, run Rubocop with ruby 3.2 [#851](https://github.com/Apipie/apipie-rails/pull/851), [#853](https://github.com/Apipie/apipie-rails/pull/853), [#840](https://github.com/Apipie/apipie-rails/pull/840), [#841](https://github.com/Apipie/apipie-rails/pull/841) (Panos Dalitsouris)
* [Rubocop] More Rubocop Auto corrections [#858](https://github.com/Apipie/apipie-rails/pull/858), [#849](https://github.com/Apipie/apipie-rails/pull/849), [#850](https://github.com/Apipie/apipie-rails/pull/850), [#844](https://github.com/Apipie/apipie-rails/pull/844), [#846](https://github.com/Apipie/apipie-rails/pull/846), [#834](https://github.com/Apipie/apipie-rails/pull/834), [#847](https://github.com/Apipie/apipie-rails/pull/847) (Rubocop Challenger)

## [v0.9.3](https://github.com/Apipie/apipie-rails/tree/v0.9.3) (2023-03-08)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.9.2...v0.9.3)
* [Feature] Allow Apipie::ParamDescription to be marked as deprecated [#819](https://github.com/Apipie/apipie-rails/pull/819), [#811](https://github.com/Apipie/apipie-rails/pull/811) (Panos Dalitsouris)
* [Fix] Make html markup thread safe ([#822](https://github.com/Apipie/apipie-rails/issues/822)) (Adam Růžička)
* [Feature] Allow action matcher strategy to be configured [#821](https://github.com/Apipie/apipie-rails/pull/821) (Panos Dalitsouris)
* [CI] Run Rubocop when opening PR [#826](https://github.com/Apipie/apipie-rails/pull/826) (Panos Dalitsouris)
* [CI] Green rubocop - Fix after rubocop challenger upgrade [#829](https://github.com/Apipie/apipie-rails/pull/829) (Mathieu Jobin)
* [Rubocop] More Rubocop Auto corrections [#818](https://github.com/Apipie/apipie-rails/pull/818), [#825](https://github.com/Apipie/apipie-rails/pull/825), [#827](https://github.com/Apipie/apipie-rails/pull/827), [#837](https://github.com/Apipie/apipie-rails/pull/837), [#839](https://github.com/Apipie/apipie-rails/pull/839) (Rubocop Challenger)

## [v0.9.2](https://github.com/Apipie/apipie-rails/tree/v0.9.2) (2023-02-07)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.9.1...v0.9.2)
* [Rubocop] More Rubocop Auto corrections [#795](https://github.com/Apipie/apipie-rails/pull/795), [#781](https://github.com/Apipie/apipie-rails/pull/781), [#791](https://github.com/Apipie/apipie-rails/pull/791), [#788](https://github.com/Apipie/apipie-rails/pull/788) (Rubocop Challenger)
* [Fix] Can't include translation in full description ([#446](https://github.com/Apipie/apipie-rails/issues/446)) [#808](https://github.com/Apipie/apipie-rails/pull/808) (Peter Nagy)
* [Refactor] Move swagger param description creation [#810](https://github.com/Apipie/apipie-rails/pull/810) (Panos Dalitsouris)
* [Rubocop] Redo rubocop TODOs, set HashSyntax config to most used style [#814](https://github.com/Apipie/apipie-rails/pull/814) (Mathieu Jobin)
* [Fix] Swagger missing i18n [#815](https://github.com/Apipie/apipie-rails/pull/815) (@jirubio)

## [v0.9.1](https://github.com/Apipie/apipie-rails/tree/v0.9.1) (2023-01-16)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.9.0...v0.9.1)
* [Refactor] Create test cache files under a not version controlled directory [#809](https://github.com/Apipie/apipie-rails/pull/809) (Panos Dalitsouris)
* [Ruby] Support for Ruby 3.2 [#807](https://github.com/Apipie/apipie-rails/pull/807) (Mathieu Jobin)
* [Fix] Reverted conditional assignment operators that caused #559 [#806](https://github.com/Apipie/apipie-rails/pull/806) (Nick L. Deltik)
* [Rubocop] Autocorrect Style/SymbolProc [#793](https://github.com/Apipie/apipie-rails/pull/793) (Rubocop Challenger)

## [v0.9.0](https://github.com/Apipie/apipie-rails/tree/v0.9.0) (2023-01-03)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.8.2...v0.9.0)
* [Refactor] Move Swagger types and warnings under `/generator` namespace [#803](https://github.com/Apipie/apipie-rails/pull/803) (Panos Dalitsouris)
* [Refactor] Creates `Apipie::MethodDescription::ApisService` [#805](https://github.com/Apipie/apipie-rails/pull/805) (Panos Dalitsouris)
* [Refactor] Change output folder to `spec/dummy/tmp/` [#804](https://github.com/Apipie/apipie-rails/pull/804) (Panos Dalitsouris)
* Fix tiny typo in docs [#798](https://github.com/Apipie/apipie-rails/pull/798) (Erik-B. Ernst)
* Fix Generated docs.json output [#787](https://github.com/Apipie/apipie-rails/pull/787) (Jeremy Liberman)
* Rubocop Fixes [#775](https://github.com/Apipie/apipie-rails/pull/775), [#778](https://github.com/Apipie/apipie-rails/pull/778), [#780](https://github.com/Apipie/apipie-rails/pull/780), [#790](https://github.com/Apipie/apipie-rails/pull/790), [#783](https://github.com/Apipie/apipie-rails/pull/783), [#785](https://github.com/Apipie/apipie-rails/pull/785) (RuboCop)
* Remove/clean up dev dependencies and unused rake tasks [#777](https://github.com/Apipie/apipie-rails/pull/777) (Mathieu Jobin)
    - remove unused rake task
* Setup Rubocop Challenger [#776](https://github.com/Apipie/apipie-rails/pull/776) (Mathieu Jobin)

## [v0.8.2](https://github.com/Apipie/apipie-rails/tree/v0.8.2) (2022-09-03)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.8.1...v0.8.2)
* Allow custom validators to opt out of allow_blank behavior [#762](https://github.com/Apipie/apipie-rails/pull/762).  (Stephen Hanson)
* Enforce test coverage, set current 89% as minimum [#764](https://github.com/Apipie/apipie-rails/pull/764). (Mathieu Jobin)
* Add contributing instructions to readme [#763](https://github.com/Apipie/apipie-rails/pull/763).  (Stephen Hanson)
* Fix readme formatting [#765](https://github.com/Apipie/apipie-rails/pull/765).  (Stephen Hanson)
* Adds expected_type to IntegerValidator example [#769](https://github.com/Apipie/apipie-rails/pull/769).  (Jeremy Liberman)
* Update readme with error handling example [#768](https://github.com/Apipie/apipie-rails/pull/768).  (Jesse Eisenberg)
* Fix scope incorrectly set to nil when a param_group is used inside an array_of_hash and the param_group is in a different module / controller. [#693](https://github.com/Apipie/apipie-rails/pull/693) [#774](https://github.com/Apipie/apipie-rails/pull/774).  (Omkar Joshi / Oliver Iyer)

## [v0.8.1](https://github.com/Apipie/apipie-rails/tree/v0.8.1) (2022-05-26)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.8.0...v0.8.1)
* Remove warning that came back as of [#752](https://github.com/Apipie/apipie-rails/pull/752). [#761](https://github.com/Apipie/apipie-rails/pull/761) (Jorge Santos / Mathieu Jobin)

## [v0.8.0](https://github.com/Apipie/apipie-rails/tree/v0.8.0) (2022-05-24)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.7.2...v0.8.0)
* Add support for scheme definition in Swagger docs. [#710](https://github.com/Apipie/apipie-rails/pull/710) (Dan Leyden)
* Add support for Rails 7 [#760](https://github.com/Apipie/apipie-rails/pull/760) (Mathieu Jobin)
* Clean up code base, removing all trace of unsupported Rails 4.x [#752](https://github.com/Apipie/apipie-rails/pull/752) (Mathieu Jobin)
* fix: Controller resource set before version [#744](https://github.com/Apipie/apipie-rails/pull/744) (LuukvH)
* fix: enable swagger generator to add referenced schema for an array of hashes param [#689](https://github.com/Apipie/apipie-rails/pull/689) (Francis San Juan)

## [v0.7.2](https://github.com/Apipie/apipie-rails/tree/v0.7.2) (2022-04-19)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.7.1...v0.7.2)
* Added Korean locale. [#480](https://github.com/Apipie/apipie-rails/pull/480) (Jaehyun Shin ) [#757](https://github.com/Apipie/apipie-rails/pull/757) (Jorge Santos)
* `Security` Upgraded Bootstrap from 2.0.2 to 2.3.2, JQuery from 1.11.3 to 1.12.4 [#708](https://github.com/Apipie/apipie-rails/pull/708) (Nicolas Waissbluth)
* Fix ruby2 keyword argument warning [#756](https://github.com/Apipie/apipie-rails/pull/756) (Jorge Santos)

## [v0.7.1](https://github.com/Apipie/apipie-rails/tree/v0.7.1) (2022-04-06)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.7.0...v0.7.1)
* Skip extra parameters while validating the keys. [#690](https://github.com/Apipie/apipie-rails/pull/690) (Omkar Joshi)
* Support defining security mechanisms for Swagger [#711](https://github.com/Apipie/apipie-rails/pull/711) (Dan Leyden)
* Update boolean handling of false [#749](https://github.com/Apipie/apipie-rails/pull/749) (Colin Bruce)

Note: Up until and including v0.6.x, apipie-rails was silently ignoring allow_blank == false on String validation.
when allow_blank is not specified, it default to false. to allow blank strings, you must specify it as a parameter.

Alternatively, if you want to revert to the previous behavior, you can set this configuration option:
`Apipie.configuration.ignore_allow_blank_false = true`.

## [v0.7.0](https://github.com/Apipie/apipie-rails/tree/v0.7.0) (2022-03-30)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.6.0...v0.7.0)
* ArgumentError (invalid byte sequence in UTF-8) [#746](https://github.com/Apipie/apipie-rails/pull/746) (David Milanese)
* Fix allow_blank does not work [#733](https://github.com/Apipie/apipie-rails/pull/733) (CHEN Song)
* Fix schema generation for param descriptions using the array validator in option [#732](https://github.com/Apipie/apipie-rails/pull/732) (Frank Hock)
* Remove support for Rails 4 and Ruby <= 2.5 [#747](https://github.com/Apipie/apipie-rails/pull/747) (Mathieu Jobin)

## [v0.6.0](https://github.com/Apipie/apipie-rails/tree/v0.6.0) (2022-03-29)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.5.20...v0.6.0)
* Ruby 3.0 fixes [#716](https://github.com/Apipie/apipie-rails/pull/716) (hank-spokeo)
* only depends on actionpack and activesupport [#741](https://github.com/Apipie/apipie-rails/pull/741) (Mathieu Jobin)
* language fix, fallback to default locale [#726](https://github.com/Apipie/apipie-rails/pull/726) (Alex Coomans)

## [v0.5.20](https://github.com/Apipie/apipie-rails/tree/v0.5.20) (2022-03-16)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.5.19...v0.5.20)
* Update rel-eng (Oleh Fedorenko)
* Deprecate travis, run tests on github actions [#740](https://github.com/Apipie/apipie-rails/pull/740) (Mathieu Jobin)
* Update validator.rb [#739](https://github.com/Apipie/apipie-rails/pull/739) (Dmytro Budnyk)
* Fix wrong number of arguments for recorder#process [#725](https://github.com/Apipie/apipie-rails/pull/725) (rob mathews)
* Change "an" to "a" [#723](https://github.com/Apipie/apipie-rails/pull/723) (Naokimi)

## [v0.5.19](https://github.com/Apipie/apipie-rails/tree/v0.5.19) (2021-07-25)
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.5.18...v0.5.19)
* Add rel-eng notebook (Oleh Fedorenko)
* Correct the word parâmentros for brazilian portuguese [#687](https://github.com/Apipie/apipie-rails/pull/687) (Diego Noronha)
* Fix depreciated file.exists. [#721](https://github.com/Apipie/apipie-rails/pull/721) (Diane Delallée)
* Fix typo in changelog [#703](https://github.com/Apipie/apipie-rails/pull/703) (Pavel Rodionov)
* Add rails 6.1 support in doc generation [#702](https://github.com/Apipie/apipie-rails/pull/702) (andrew-newell)


[v0.5.18](https://github.com/Apipie/apipie-rails/tree/v0.5.18) (2020-05-20)
--------

[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.5.17...v0.5.18)

- Optional rdoc dependency with lazyload [\#683](https://github.com/Apipie/apipie-rails/pull/683) ([vkrizan](https://github.com/vkrizan))

[v0.5.17](https://github.com/Apipie/apipie-rails/tree/v0.5.17) (2020-01-20)
--------

[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.5.16...v0.5.17)

- Allows update metadata for methods [\#667](https://github.com/Apipie/apipie-rails/pull/667) ([speckins](https://github.com/speckins))

[v0.5.16](https://github.com/Apipie/apipie-rails/tree/v0.5.16) (2019-05-22)
--------

[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.5.15...v0.5.16)

- Load file directly instead of using Rails constant [\#665](https://github.com/Apipie/apipie-rails/pull/665) ([speckins](https://github.com/speckins))

[v0.5.15](https://github.com/Apipie/apipie-rails/tree/v0.5.15) (2019-01-03)
--------
[Full Changelog](https://github.com/Apipie/apipie-rails/compare/v0.5.14...v0.5.15)


- Fix authorization of resources [\#655](https://github.com/Apipie/apipie-rails/pull/655) ([NielsKSchjoedt](https://github.com/NielsKSchjoedt))
- Use configured value when swagger\_content\_type\_input argument is not passed [\#648](https://github.com/Apipie/apipie-rails/pull/648) ([nullnull](https://github.com/nullnull))
- Fix "ArgumentError: string contains null byte" on malformed stings [\#477](https://github.com/Apipie/apipie-rails/pull/477) ([avokhmin](https://github.com/avokhmin))

v0.5.14
-------
- HTML escape validator values [\#645](https://github.com/Apipie/apipie-rails/pull/645) ([ekohl](https://github.com/ekohl))
- Support for adding new params via `update\_api` [\#642](https://github.com/Apipie/apipie-rails/pull/642) ([iNecas](https://github.com/iNecas))
- Allow the "null" JSON string to be used as a parameter in Apipie spec examples \(`show\_in\_doc`\) [\#641](https://github.com/Apipie/apipie-rails/pull/641) ([enrique-guillen](https://github.com/enrique-guillen))
- Fix examples recording for specific cases  [\#640](https://github.com/Apipie/apipie-rails/pull/640) ([Marri](https://github.com/Marri))
- Add description section to response [\#639](https://github.com/Apipie/apipie-rails/pull/639) ([X1ting](https://github.com/X1ting))


v0.5.13
-------
-  Fix swagger generation if a controller's parent doesn't define a resource_description [\#637](https://github.com/Apipie/apipie-rails/pull/637) ([enrique-guillen](https://github.com/enrique-guillen))

v0.5.12
-------
- Fix returns displaying [\#635](https://github.com/Apipie/apipie-rails/pull/635) ([X1ting](https://github.com/X1ting))

v0.5.11
-------

- Adds swagger tags in swagger output [\#634](https://github.com/Apipie/apipie-rails/pull/634) ([enrique-guillen](https://github.com/enrique-guillen))
- Generate swagger with headers [\#630](https://github.com/Apipie/apipie-rails/pull/630) ([Uysim](https://github.com/Uysim))
- Fix examples not being generated for Rails < 5.0.0 [\#633](https://github.com/Apipie/apipie-rails/pull/633) ([RomanKapitonov](https://github.com/RomanKapitonov))

v0.5.10
------

- Support response validation [\#626](https://github.com/Apipie/apipie-rails/pull/626) ([COzero](https://github.com/COzero))

v0.5.9
------

- Support response validation [\#619](https://github.com/Apipie/apipie-rails/pull/619) ([abenari](https://github.com/abenari))
- Expect :number to have type 'numeric' [\#614](https://github.com/Apipie/apipie-rails/pull/614) ([akofink](https://github.com/akofink))
- New validator - DecimalValidator [\#431](https://github.com/Apipie/apipie-rails/pull/431) ([kiddrew](https://github.com/kiddrew))


v0.5.8
------

- Swagger json includes apipie's description as swagger's description [\#615](https://github.com/Apipie/apipie-rails/pull/615) ([gogotanaka](https://github.com/gogotanaka))
- Fix api! issue by using underscore when appending `controller` to the default controller string [\#613](https://github.com/Apipie/apipie-rails/pull/613) ([kevinmarx](https://github.com/kevinmarx))
- Possibility to compress examples [\#600](https://github.com/Apipie/apipie-rails/pull/600) ([Haniyya](https://github.com/Haniyya))
- Possibility to describe responses [\#588](https://github.com/Apipie/apipie-rails/pull/588) ([elasti-ron](https://github.com/elasti-ron))

v0.5.7
------

- Fix example recording with Rails 5 [\#607](https://github.com/Apipie/apipie-rails/pull/607) ([adamruzicka](https://github.com/adamruzicka))
- Use SHA1 instead of MD5 to enable using APIPIE at FIPS-enables systems [\#605](https://github.com/Apipie/apipie-rails/pull/605) ([iNecas](https://github.com/iNecas))
- Replaced String\#constantize with String\#safe\_constantize so apipie won't break on a missing constant [\#575](https://github.com/Apipie/apipie-rails/pull/575) ([Haniyya](https://github.com/Haniyya))
- Added Swagger generation [\#569](https://github.com/Apipie/apipie-rails/pull/569) ([elasti-ron](https://github.com/elasti-ron))

v0.5.6
------

- Prevent missing translation span in title [\#571](https://github.com/Apipie/apipie-rails/pull/571) ([mbacovsky](https://github.com/mbacovsky))
- Clean up old generator code for CLI [\#572](https://github.com/Apipie/apipie-rails/pull/572) ([voxik](https://github.com/voxik))
- Added french locale [\#568](https://github.com/Apipie/apipie-rails/pull/568) ([giglemad](https://github.com/giglemad))

v0.5.5
------

- prevent lang in url when config.translate is false [\#562](https://github.com/Apipie/apipie-rails/pull/562) ([markmoser](https://github.com/markmoser))
- Allow for resource-level deprecations [\#567](https://github.com/Apipie/apipie-rails/pull/567) ([cross-p6](https://github.com/cross-p6))

v0.5.4
------

- Constantize controller class before calling superclass [\#558](https://github.com/Apipie/apipie-rails/pull/558) ([ydkn](https://github.com/ydkn))

v0.5.3
------

- Fix reloading when extending the apidoc from concern [\#557](https://github.com/Apipie/apipie-rails/pull/557) ([iNecas](https://github.com/iNecas))
- Fix example recording when using send\_file [\#504](https://github.com/Apipie/apipie-rails/pull/504) ([tdeo](https://github.com/tdeo))

v0.5.2
------

- A way to extend an exiting API via concern [\#554](https://github.com/Apipie/apipie-rails/pull/554) ([iNecas](https://github.com/iNecas))
- Fallback to apipie views when application override isn't present [\#552](https://github.com/Apipie/apipie-rails/pull/552) ([tstrachota](https://github.com/tstrachota))
- Updated setting default locale for api documentation [\#543](https://github.com/Apipie/apipie-rails/pull/543) ([DmitryKK](https://github.com/DmitryKK))

v0.5.1
------

- Use AD::Reloader on Rails 4, app.reloader only on Rails 5+ [\#541](https://github.com/Apipie/apipie-rails/pull/541) ([domcleal](https://github.com/domcleal))
- Recognize Rack Symbols as Status Codes [\#468](https://github.com/Apipie/apipie-rails/pull/468)([alex-tan](https://github.com/alex-tan))

v0.5.0
------

- Fix Rails 5.1 deprecations [\#530](https://github.com/Apipie/apipie-rails/pull/530) ([@Onumis](https://github.com/Onumis) [@sedx](https://github.com/sedx))
  - **This release is no longer compatible with Ruby 1.9.x**
- Do not mutate strings passed as config options, fixes \#461 [\#537](https://github.com/Apipie/apipie-rails/pull/537) ([samphilipd](https://github.com/samphilipd))
- Added recursion for documentation, fixed bug in examples with paperclip [\#531](https://github.com/Apipie/apipie-rails/pull/531) ([blddmnd](https://github.com/blddmnd))
- Added locales/ja.yml for Japanese [\#529](https://github.com/Apipie/apipie-rails/pull/529) ([kikuchi0808](https://github.com/kikuchi0808))


v0.4.0
------

- Rails 5 compatibility [\#527](https://github.com/Apipie/apipie-rails/pull/527) ([iNecas](https://github.com/iNecas)) [\#420](https://github.com/Apipie/apipie-rails/pull/420) ([buren](https://github.com/buren)) [\#473](https://github.com/Apipie/apipie-rails/pull/473)([domcleal](https://github.com/domcleal))
  - **This release is no longer compatible with Rails 3.x**
- Include delete request parmeters in generated documentation [\#524](https://github.com/Apipie/apipie-rails/pull/524) ([johnnaegle](https://github.com/johnnaegle))
- Allow a blank, not just nil, base\_url. [\#521](https://github.com/Apipie/apipie-rails/pull/521) ([johnnaegle](https://github.com/johnnaegle))
- Adds allow\_blank option [\#508](https://github.com/Apipie/apipie-rails/pull/508) ([MrLeebo](https://github.com/MrLeebo))
- Boolean Validator uses \<code\> instead of ' [\#502](https://github.com/Apipie/apipie-rails/pull/502) ([berfarah](https://github.com/berfarah))
- Fix type validator message [\#501](https://github.com/Apipie/apipie-rails/pull/501) ([cindygu-itglue](https://github.com/cindygu-itglue))
- Add IT locale [\#496](https://github.com/Apipie/apipie-rails/pull/496) ([alepore](https://github.com/alepore))
- Fix small typo on dsl\_definition data init [\#494](https://github.com/Apipie/apipie-rails/pull/494) ([begault](https://github.com/begault))
- Localize app info message [\#491](https://github.com/Apipie/apipie-rails/pull/491) ([belousovAV](https://github.com/belousovAV))
- Fix travis build [\#489](https://github.com/Apipie/apipie-rails/pull/489) ([mtparet](https://github.com/mtparet))
- Handle blank data when parsing a example's response [\#453](https://github.com/Apipie/apipie-rails/pull/453) ([stbenjam](https://github.com/stbenjam))
- Allow layouts to be overridable. Fixes a regression introduced in \#425. [\#447](https://github.com/Apipie/apipie-rails/pull/447) ([nilsojes](https://github.com/nilsojes))

v0.3.7
------

- Handle blank data when parsing a example's response [\#453](https://github.com/Apipie/apipie-rails/pull/453) ([stbenjam](https://github.com/stbenjam))
- Allow layouts to be overridable. Fixes a regression introduced in \#425. [\#447](https://github.com/Apipie/apipie-rails/pull/447) ([nilseriksson](https://github.com/nilseriksson))

v0.3.6
------

- Fixed to\_json encoding error that occurs with uploaded file parameters. [\#429](https://github.com/Apipie/apipie-rails/pull/429) ([hossenlopp](https://github.com/hossenlopp))
- Render enum param values as CODE [\#426](https://github.com/Apipie/apipie-rails/pull/426) ([febeling](https://github.com/febeling))
- Fix layout path \(Rails 4.2.5.1 compatibility\) [\#425](https://github.com/Apipie/apipie-rails/pull/425) ([halilim](https://github.com/halilim))
- Unify indentations across all locale files [\#423](https://github.com/Apipie/apipie-rails/pull/423) ([springerigor](https://github.com/springerigor))
- Fix typo in Action Aware Params section of readme [\#419](https://github.com/Apipie/apipie-rails/pull/419) ([ryanlabouve](https://github.com/ryanlabouve))
- Rails4.2 [\#413](https://github.com/Apipie/apipie-rails/pull/413) ([ferdinandrosario](https://github.com/ferdinandrosario))
- Add viewport meta tag. [\#412](https://github.com/Apipie/apipie-rails/pull/412) ([buren](https://github.com/buren))
- removed beta version [\#411](https://github.com/Apipie/apipie-rails/pull/411) ([ferdinandrosario](https://github.com/ferdinandrosario))
- updated patch [\#410](https://github.com/Apipie/apipie-rails/pull/410) ([ferdinandrosario](https://github.com/ferdinandrosario))
- Nerian layout fix [\#409](https://github.com/Apipie/apipie-rails/pull/409) ([Pajk](https://github.com/Pajk))
- Add Turkish translations [\#407](https://github.com/Apipie/apipie-rails/pull/407) ([halilim](https://github.com/halilim))
- Update README.rst [\#405](https://github.com/Apipie/apipie-rails/pull/405) ([type-face](https://github.com/type-face))
- add german locale [\#394](https://github.com/Apipie/apipie-rails/pull/394) ([mjansing](https://github.com/mjansing))
- Add custom message support for missing parameters  [\#390](https://github.com/Apipie/apipie-rails/pull/390) ([jcalvert](https://github.com/jcalvert))
- A boolean parameters can be configured with both :bool and :boolean [\#124](https://github.com/Apipie/apipie-rails/pull/124) ([Nerian](https://github.com/Nerian))

v0.3.5
------

* Cleaning up unreachable code
  [#385](https://github.com/Apipie/apipie-rails/pull/385) [@voxik][]
* Russian translation
  [#352](https://github.com/Apipie/apipie-rails/pull/352) [@Le6ow5k1][]
* Ability to hide controller methods from documentation
  [#356](https://github.com/Apipie/apipie-rails/pull/356) [@davidcollie][]
* Use doc_path configuration in rake tasks
  [#358](https://github.com/Apipie/apipie-rails/pull/358)  [@saneshark][]
* Chinese translation
  [#363](https://github.com/Apipie/apipie-rails/pull/363)  [@debbbbie][]
* Polish translation
  [#375](https://github.com/Apipie/apipie-rails/pull/375)  [@dbackowski][]
* Spanish translation
  [#376](https://github.com/Apipie/apipie-rails/pull/376)  [@isseu][]
* Add an alternative to action aware required param
  [#377](https://github.com/Apipie/apipie-rails/pull/377)  [@mourad-ifeelgoods][]

v0.3.4
------

* Fixing occasional NoMethodError with ActionDispatch::Reloader
  [#348](https://github.com/Apipie/apipie-rails/pull/348) [@saneshark][]
* Portuguese translation
  [#344](https://github.com/Apipie/apipie-rails/pull/344) [@dadario][]

v0.3.3
------

* Support for describing headers
  [#341](https://github.com/Apipie/apipie-rails/pull/341) [@iliabylich][]

v0.3.2
------

* PATCH support for examples recording
  [#332](https://github.com/Apipie/apipie-rails/pull/332) [@akenger][]
* Recursively search for API controllers by default for new projects
  [#333](https://github.com/Apipie/apipie-rails/pull/333) [@baweaver][]
* Handling recursive route definitions with `api!` keyword
  [#338](https://github.com/Apipie/apipie-rails/pull/338) [@stormsilver][]
* Support for eager-loaded controllers
  [#329](https://github.com/Apipie/apipie-rails/pull/329) [@mtparet][]

v0.3.1
------

* Support for ``api!`` keyword in concerns
  [#322](https://github.com/Apipie/apipie-rails/pull/322) [@iNecas][]
* More explicit ordering of the static dispatcher middleware
  [#315](https://github.com/Apipie/apipie-rails/pull/315) [@iNecas][]

v0.3.0
------
This should be a backward compatible release. However, the number of new
significant features deserves new minor version bump.

* Rubocop-blessed Ruby 1.9 syntax for generated DSL documentation
  [#318](https://github.com/Apipie/apipie-rails/pull/318) [@burnettk][]
* load API paths from routes.rb
  [#187](https://github.com/Apipie/apipie-rails/pull/187) [@mtparet][] [@iNecas][]
* ability to use before_filter instead of overriding the action method
  for validation
  [#306](https://github.com/Apipie/apipie-rails/pull/306) [@dprice-fiksu][]
* support multi-part data when recording from tests
  [#310](https://github.com/Apipie/apipie-rails/pull/310) [@bradrf][]
* validate_keys option to raise exception when passing undocumented option
  [#122](https://github.com/Apipie/apipie-rails/pull/122) [@dfharmon][]
* handle static page generation when the doc_base_url has multiple folders
  [#300](https://github.com/Apipie/apipie-rails/pull/300) [@ryanische][]
* add ability to markup validator description
  [#282](https://github.com/Apipie/apipie-rails/pull/282) [@exAspArk][]
* don't specify protocol in Disqus script tag src
  [#285](https://github.com/Apipie/apipie-rails/pull/285) [@chrise86][]
* fix BooleanValidator to set expected_type as boolean
  [#286](https://github.com/Apipie/apipie-rails/pull/286) [@dustin-rh][]


v0.2.6
------

* better handling on cases where resource/method is not found when cache is turned off
  [#284](https://github.com/Apipie/apipie-rails/pull/284) [@iNecas][]
* fix disqus integration
  [#281](https://github.com/Apipie/apipie-rails/pull/281) [@RajRoR][]

v0.2.5
------

* Name substitution for referenced param_group defined in a concern
  [#280](https://github.com/Apipie/apipie-rails/pull/280) [@tstrachota][]
* expected_type 'array' for ArrayValidator
  [#276](https://github.com/Apipie/apipie-rails/pull/276) [@dustint-rh][]

THE FURTHER SUPPORT FOR RUBY 1.8.7 WILL NOT BE ENSURED IN THE MASTER
AND THE `>= 0.3.0` RELAEASES. We discourage anyone to keep using ruby
1.8.7 for anything. If you're aware of the issues and still willing to
take the risk, we are willing to keep the v0.2.x releases based on the
v0.2.x branch. However, we will not actively develop or backport any
new features to this branch neither will we accept there features that
are not in the master branch.

v0.2.4
------

* fix ruby 1.8.7 compatibility
  [#272](https://github.com/Apipie/apipie-rails/pull/272) [@domcleal][]

v0.2.3
------

* add an option to flag an api route as deprecated
  [#268](https://github.com/Apipie/apipie-rails/pull/268) [@komidore64][]
* add ability to pass additional options to apipie route
  [#269](https://github.com/Apipie/apipie-rails/pull/269) [@exAspArk][]
* enhanced array validator
  [#259](https://github.com/Apipie/apipie-rails/pull/259) [@mourad-ifeelgoods][]


v0.2.2
------

* prevent rspec 3 from being used. It is not compatible.
  [#255](https://github.com/Apipie/apipie-rails/pull/255) [@lsylvester][]
* fixed extractor root route (handle nil path)
  [#257](https://github.com/Apipie/apipie-rails/pull/257) [@ctria][]
* reduced rails dependency to development only
  [#266](https://github.com/Apipie/apipie-rails/pull/266) [@klobuczek][]
* add more options to apipie:cache to generate only parts of the
  static pages
  [#262](https://github.com/Apipie/apipie-rails/pull/262) [@mbacovsky][]

v0.2.1
------

* fix typo in the localization string
  [#244](https://github.com/Apipie/apipie-rails/pull/244) [@alem0lars][]
* fix syntax errors in 404 page
  [#246](https://github.com/Apipie/apipie-rails/pull/246) [@richardsondx][]


v0.2.0
------

This is not full backward compatible release, as the format of storing
examples changed from YAML to JSON: the default location is at
`doc/apipie_examples.json`. The migration should be as easy as
running:

```
rake apipie:convert_examples
```

Also please not Rails 3.0 support was deprecated and the compatibility
wont be tracked anymore in next releases.

* dump examples as json
  [#125](https://github.com/Apipie/apipie-rails/pull/125) [@johanneswuerbach][]
* support for localized API documentation
  [#232](https://github.com/Apipie/apipie-rails/pull/232) [@mbacovsky][]
* configuration option to always record examples
  [#239](https://github.com/Apipie/apipie-rails/pull/239) [@arathunku][]
* deprecate Rails 3.0
  [#241](https://github.com/Apipie/apipie-rails/pull/241) [@iNecas][]

v0.1.3
------

* nested attributes showing in the documentation
  [#230](https://github.com/Apipie/apipie-rails/pull/230) [@iNecas][]

v0.1.2
------

* reloading works correctly with to_prepare blocks in the app
  [#228](https://github.com/Apipie/apipie-rails/pull/228) [@iNecas][]
* documentation bootstrapping now respects api_controllers_matcher
  [#227](https://github.com/Apipie/apipie-rails/pull/227) [@clamoris][]

v0.1.1
------

* backward compatibility with Ruby 1.8 [#218](https://github.com/Apipie/apipie-rails/pull/218) [@mbacovsky][]
* checksum calculation is lazy and respect use_cache config [#220](https://github.com/Apipie/apipie-rails/pull/220) [@mbacovsky][]
* fix generating the cache in production environment [#223](https://github.com/Apipie/apipie-rails/pull/223) [@iNecas][]
* fix loading regression with SafeYAML [#224](https://github.com/Apipie/apipie-rails/pull/224) [@iNecas][]

v0.1.0
------

* middleware for computing Apipie checksum for [dynamic bindings](https://github.com/Apipie/apipie-bindings) [#215](https://github.com/Apipie/apipie-rails/pull/215) [@mbacovsky][]
* `api_base_url` inherited properly [#214](https://github.com/Apipie/apipie-rails/pull/214) [@mbacovsky][]
* ability to hide specific parameters [#208](https://github.com/Apipie/apipie-rails/pull/208) [@nathanhoel][]
* fix for SafeYAML compatibility [#207](https://github.com/Apipie/apipie-rails/pull/207) [@pivotalshiny][]
* option to show all examples in the documentation [#203](https://github.com/Apipie/apipie-rails/pull/203) [@pivotalshiny][]
* support for array of hashes validation [#189](https://github.com/Apipie/apipie-rails/pull/189) [@mtparet][]
* support for saving the values based on documentation into `@api_params` variable [#188](https://github.com/Apipie/apipie-rails/pull/188) [@mtparet][]
* support for json generated from rake task `rake apipie:static_json` [#186](https://github.com/Apipie/apipie-rails/pull/186) [@mtparet][]
* fix `undefined method 'has_key?' for nil:NilClass` when validating Hash against non-hash value [#185](https://github.com/Apipie/apipie-rails/pull/185) [@mtparet][]
* fix NoMethorError when validating Hash against non-hash value  [#183](https://github.com/Apipie/apipie-rails/pull/183) [@nathanhoel][]
* support for metadata for params [#181](https://github.com/Apipie/apipie-rails/pull/181) [@tstrachota][]
* fix camelization of class names [#170](https://github.com/Apipie/apipie-rails/pull/170) [@yonpols][]
* new array class validator [#169](https://github.com/Apipie/apipie-rails/pull/169) [@mkrajewski][]

v0.0.24
-------

* fix DOS vulnerability for running in production without use_cache
* ability to load descriptions from external files
* improved examples extractor
* fixed deprecation warnings in Rails 4
* using StandardError instead of Exception for errors

v0.0.23
-------

* fix exceptions on unknown validator
* fix concerns substitution in parameters
* possibility to authenticate the API doc
* support for array in api_controllers_matcher

v0.0.22
-------

* fix "named_resources" option
* fix generating static files when concerns used

v0.0.21
-------

* fix RDoc 4.0 compatibility issue
* ``validate_value`` and ``validate_presence`` options for better
  validation granularity

v0.0.20
-------

* namespaced resources - prevent collisions when one resource defined
  in more modules
* ``Apipie::DSL::Concern`` for being able to use the DSL in module
  that is included into controllers

v0.0.19
-------

* fix examples recording when resource_id is set
* use safe_yaml for loading examples file when available

v0.0.18
-------

* ``param_group`` and ``def_param_group`` keywords
* ``:action_aware`` options for reusing param groups for create/update actions

v0.0.17
-------

* support for multiple see links at action and ability to provide
  description of see links

v0.0.16
-------

* Fix getting started being rendered even when documentation was available

v0.0.15
-------

* Fix case when there is no documentation yet: with link to how to
  start
* Fix handling bad requests when cache is on
* Fix params extractor in case there is already some documentation

[@mbacovsky]: https://github.com/mbacovsky
[@tstrachota]: https://github.com/tstrachota
[@nathanhoel]: https://github.com/nathanhoel
[@pivotalshiny]: https://github.com/pivotalshiny
[@mtparet]: https://github.com/mtparet
[@yonpols]: https://github.com/yonpols
[@mkrajewski]: https://github.com/mkrajewski
[@iNecas]: https://github.com/iNecas
[@clamoris]: https://github.com/clamoris
[@arathunku]: https://github.com/arathunku
[@johanneswuerbach]: https://github.com/johanneswuerbach
[@richardsondx]: https://github.com/richardsondx
[@alem0lars]: https://github.com/alem0lars
[@lsylvester]: https://github.com/lsylverster
[@ctria]: https://github.com/ctria
[@klobuczek]: https://github.com/klobuczek
[@komidore64]: https://github.com/komidore64
[@exAspArk]: https://github.com/exAspArk
[@mourad-ifeelgoods]: https://github.com/mourad-ifeelgoods
[@domcleal]: https://github.com/domcleal
[@dustin-rh]: https://github.com/dustin-rh
[@RajRoR]: https://github.com/RajRoR
[@chrise86]: https://github.com/chrise86
[@ryanische]: https://github.com/ryanische
[@dfharmon]: https://github.com/dfharmon
[@bradrf]: https://github.com/bradrf
[@dprice-fiksu]: https://github.com/dprice-fiksu
[@burnettk]: https://github.com/burnettk
[@akenger]: https://github.com/akenger
[@baweaver]: https://github.com/baweaver
[@stormsilver]: https://github.com/stormsilver
[@iliabylich]: https://github.com/iliabylich
[@dadario]: https://github.com/dadario
[@saneshark]: https://github.com/saneshark
[@voxik]: https://github.com/voxik
[@Le6ow5k1]: https://github.com/Le6ow5k1
[@davidcollie]: https://github.com/davidcollie
[@saneshark]: https://github.com/saneshark
[@debbbbie]: https://github.com/debbbbie
[@dbackowski]: https://github.com/dbackowski
[@isseu]: https://github.com/isseu
