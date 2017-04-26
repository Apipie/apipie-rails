 Changelog
===========

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
