===========
 Changelog
===========


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
