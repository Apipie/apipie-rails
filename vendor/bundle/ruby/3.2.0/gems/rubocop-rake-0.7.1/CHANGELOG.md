# Change log

## master (unreleased)

## 0.7.1 (2025-02-16)

### Bug fixes

* [#59](https://github.com/rubocop/rubocop-rake/pull/59): Fix incorrect plugin version when displaing `rubocop -V`. ([@koic][])

## 0.7.0 (2025-02-16)

### New features

* [#58](https://github.com/rubocop/rubocop-rake/pull/58): Pluginfy RuboCop Rake. ([@koic][])

### Changes

* [#57](https://github.com/rubocop/rubocop-rake/pull/57): Drop support Ruby 2.5 and 2.6 for runtime environment. ([@koic][])

## 0.6.0 (2021-06-29)

### Changes

* [#33](https://github.com/rubocop/rubocop-rake/pull/33): Drop support for Ruby 2.3. ([@koic][])
* [#34](https://github.com/rubocop/rubocop-rake/pull/34): Require RuboCop 1.0 or higher. ([@koic][])
* [#38](https://github.com/rubocop/rubocop-rake/pull/37): Drop support for Ruby 2.4. ([@tejasbubane])
* [#36](https://github.com/rubocop/rubocop-rake/issues/36): Fix `Rake/Desc` to not generate offense for prerequisite declarations. ([@tejasbubane][])

## 0.5.1 (2020-02-14)

### Bug fixes

* [#28](https://github.com/rubocop/rubocop-rake/issues/28): Fix `Rake/Desc` to avoid an error when `task` is not a task definition. ([@pocke][])

## 0.5.0 (2019-10-31)

### New features

* [#14](https://github.com/rubocop/rubocop-rake/issues/14): Add Rake/DuplicateNamespace cop. ([@jaruuuu][])

## 0.4.0 (2019-10-13)

### New features

* [#13](https://github.com/rubocop/rubocop-rake/issues/13): Add Rake/DuplicateTask cop. ([@pocke][])

## 0.3.1 (2019-10-06)

### Bug fixes

* [#17](https://github.com/rubocop/rubocop-rake/pull/17): Filter target files for Rake/ClassDefinitionInTask cop. ([@pocke][])

## 0.3.0 (2019-09-25)

### New features

* [#6](https://github.com/rubocop/rubocop-rake/issues/6): Add `Rake/ClassDefinitionInTask` cop. ([@pocke][])

### Bug fixes

* [#8](https://github.com/rubocop/rubocop-rake/issues/8): Make Rake/Desc to not require description for the default task. ([@pocke][])

## 0.2.0 (2019-09-17)

### New features

* [#5](https://github.com/rubocop/rubocop-rake/pull/5): Add `Rake/MethodDefinitionInTask`. ([@pocke][])

## 0.1.0 (2019-09-04)

### New features

* The first release!
* Add `Rake/Desc`. ([@pocke][])

[@pocke]: https://github.com/pocke
[@jaruuuu]: https://github.com/jaruuuu
[@koic]: https://github.com/koic
[@tejasbubane]: https://github.com/tejasbubane
