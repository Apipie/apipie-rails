===========
 Changelog
===========

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
