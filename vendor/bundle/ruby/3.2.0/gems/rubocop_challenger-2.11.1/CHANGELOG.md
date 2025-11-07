# Change log

## v2.11.1 (Mar 07, 2023)

### Bugfix

- [#702](https://github.com/ryz310/rubocop_challenger/pull/702) Fix the runtime dependency ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#701](https://github.com/ryz310/rubocop_challenger/pull/701) Re-generate .rubocop_todo.yml with RuboCop v1.47.0 ([@ryz310](https://github.com/ryz310))

## v2.11.0 (Feb 15, 2023)

### Feature

- [#694](https://github.com/ryz310/rubocop_challenger/pull/694) Support `--only-exclude` option ([@shima-zu](https://github.com/shima-zu))

### Rubocop Challenge

- [#692](https://github.com/ryz310/rubocop_challenger/pull/692) Re-generate .rubocop_todo.yml with RuboCop v1.45.1 ([@ryz310](https://github.com/ryz310))

## v2.10.0 (Feb 12, 2023)

### Feature

- [#688](https://github.com/ryz310/rubocop_challenger/pull/688) Support ruby 3.2 ([@ryz310](https://github.com/ryz310))

### Bugfix

- [#686](https://github.com/ryz310/rubocop_challenger/pull/686) Skip bundle update if gems not related to rubocop ([@ryz310](https://github.com/ryz310))
- [#687](https://github.com/ryz310/rubocop_challenger/pull/687) Fix the cop class loader ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#683](https://github.com/ryz310/rubocop_challenger/pull/683) Re-generate .rubocop_todo.yml with RuboCop v1.41.1 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#644](https://github.com/ryz310/rubocop_challenger/pull/644) Update pr_comet requirement from >= 0.5.1, < 0.7.0 to >= 0.5.1, < 0.8.0 ([@ryz310](https://github.com/ryz310))
- [#649](https://github.com/ryz310/rubocop_challenger/pull/649) Bump pry-byebug from 3.10.0 to 3.10.1 ([@ryz310](https://github.com/ryz310))
- [#657](https://github.com/ryz310/rubocop_challenger/pull/657) Bump rspec_junit_formatter from 0.5.1 to 0.6.0 ([@ryz310](https://github.com/ryz310))
- [#660](https://github.com/ryz310/rubocop_challenger/pull/660) Bump rspec from 3.11.0 to 3.12.0 ([@ryz310](https://github.com/ryz310))
- [#665](https://github.com/ryz310/rubocop_challenger/pull/665) Bump rubocop-performance from 1.15.0 to 1.15.1 ([@ryz310](https://github.com/ryz310))
- [#666](https://github.com/ryz310/rubocop_challenger/pull/666) ryz310/dependabot/bundler/rubocop-rails-2.17.3 ([@ryz310](https://github.com/ryz310))
- [#674](https://github.com/ryz310/rubocop_challenger/pull/674) Update simplecov requirement from = 0.21.2 to = 0.22.0 ([@ryz310](https://github.com/ryz310))

## v2.9.0 (Jun 02, 2022)

### Feature

- [#628](https://github.com/ryz310/rubocop_challenger/pull/628) Change `auto-correct` to `autocorrect` ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#629](https://github.com/ryz310/rubocop_challenger/pull/629) Bump yard from 0.9.27 to 0.9.28 ([@ryz310](https://github.com/ryz310))

## v2.8.0 (May 30, 2022)

### Feature

- [#616](https://github.com/ryz310/rubocop_challenger/pull/616) Support `--no-offense-counts` option ([@ryz310](https://github.com/ryz310))
- [#625](https://github.com/ryz310/rubocop_challenger/pull/625) Use `--conservative` option on `bundle update` ([@ryz310](https://github.com/ryz310))

### Bugfix

- [#612](https://github.com/ryz310/rubocop_challenger/pull/612) Fix wrong usage of `Array#reject!`: this might return nil ([@r7kamura](https://github.com/r7kamura))

### Breaking Change

- [#615](https://github.com/ryz310/rubocop_challenger/pull/615) The end of ruby 2.6 support ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#624](https://github.com/ryz310/rubocop_challenger/pull/624) Re-generate .rubocop_todo.yml with RuboCop v1.30.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#608](https://github.com/ryz310/rubocop_challenger/pull/608) Update pr_comet requirement from ~> 0.5.1 to >= 0.5.1, < 0.7.0 ([@ryz310](https://github.com/ryz310))
- [#610](https://github.com/ryz310/rubocop_challenger/pull/610) Bump activesupport from 6.1.5.1 to 6.1.6 ([@ryz310](https://github.com/ryz310))

### Misc

- [#614](https://github.com/ryz310/rubocop_challenger/pull/614) Tweak some words improved representation ([@ydah](https://github.com/ydah))
- [#619](https://github.com/ryz310/rubocop_challenger/pull/619) git mv ./images/decrease_of_offen{c,s}e_codes.png ([@r7kamura](https://github.com/r7kamura))

## v2.7.0 (May 08, 2022)

### Feature

- [#605](https://github.com/ryz310/rubocop_challenger/pull/605) Support ruby 3.1 ([@ryz310](https://github.com/ryz310))
- [#580](https://github.com/ryz310/rubocop_challenger/pull/580) Modify the description of whether it is safe auto-correct ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#586](https://github.com/ryz310/rubocop_challenger/pull/586) Re-generate .rubocop_todo.yml with RuboCop v1.27.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#581](https://github.com/ryz310/rubocop_challenger/pull/581) Bump activesupport from 6.1.4.7 to 6.1.5 ([@ryz310](https://github.com/ryz310))
- [#584](https://github.com/ryz310/rubocop_challenger/pull/584) Bump rubocop-rails from 2.14.1 to 2.14.2 ([@ryz310](https://github.com/ryz310))

## v2.6.0 (Mar 10, 2022)

### Feature

- [#577](https://github.com/ryz310/rubocop_challenger/pull/577) Support new auto-correction comments at rubocop v1.26.0 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#573](https://github.com/ryz310/rubocop_challenger/pull/573) RSpec/BeNil-20220228233046 ([@ryz310](https://github.com/ryz310))
- [#576](https://github.com/ryz310/rubocop_challenger/pull/576) Re-generate .rubocop_todo.yml with RuboCop v1.26.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#571](https://github.com/ryz310/rubocop_challenger/pull/571) Bump rspec from 3.10.0 to 3.11.0 ([@ryz310](https://github.com/ryz310))
- [#574](https://github.com/ryz310/rubocop_challenger/pull/574) Bump rubocop-performance from 1.13.2 to 1.13.3 ([@ryz310](https://github.com/ryz310))
- [#575](https://github.com/ryz310/rubocop_challenger/pull/575) Bump activesupport from 6.1.4.6 to 6.1.4.7 ([@ryz310](https://github.com/ryz310))

## v2.5.0 (Jan 18, 2022)

### Feature

- [#566](https://github.com/ryz310/rubocop_challenger/pull/566) Support rubocop thread safety ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#554](https://github.com/ryz310/rubocop_challenger/pull/554) ryz310/rubocop-challenge/20211226233047 ([@ryz310](https://github.com/ryz310))
- [#555](https://github.com/ryz310/rubocop_challenger/pull/555) ryz310/rubocop-challenge/20211231233046 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#556](https://github.com/ryz310/rubocop_challenger/pull/556) Bump rubocop-performance from 1.13.0 to 1.13.1 ([@ryz310](https://github.com/ryz310))
- [#561](https://github.com/ryz310/rubocop_challenger/pull/561) Bump rubocop-rails from 2.13.0 to 2.13.1 ([@ryz310](https://github.com/ryz310))
- [#560](https://github.com/ryz310/rubocop_challenger/pull/560) Bump rspec_junit_formatter from 0.4.1 to 0.5.1 ([@ryz310](https://github.com/ryz310))
- [#559](https://github.com/ryz310/rubocop_challenger/pull/559) ryz310/dependabot/bundler/thor-1.2.1 ([@ryz310](https://github.com/ryz310))
- [#562](https://github.com/ryz310/rubocop_challenger/pull/562) Bump rainbow from 3.0.0 to 3.1.1 ([@ryz310](https://github.com/ryz310))

## v2.4.0 (Dec 26, 2021)

### Feature

- [#550](https://github.com/ryz310/rubocop_challenger/pull/550) The end of ruby 2.5 support ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#544](https://github.com/ryz310/rubocop_challenger/pull/544) Gemspec/RequireMFA-20211115233051 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#479](https://github.com/ryz310/rubocop_challenger/pull/479) ryz310/dependabot/bundler/rubocop-1.13.0 ([@ryz310](https://github.com/ryz310))
- [#482](https://github.com/ryz310/rubocop_challenger/pull/482) ryz310/dependabot/bundler/rubocop-rspec-2.3.0 ([@ryz310](https://github.com/ryz310))
- [#483](https://github.com/ryz310/rubocop_challenger/pull/483) ryz310/dependabot/add-v2-config-file ([@ryz310](https://github.com/ryz310))
- [#518](https://github.com/ryz310/rubocop_challenger/pull/518) Bump rake from 13.0.4 to 13.0.6 ([@ryz310](https://github.com/ryz310))
- [#537](https://github.com/ryz310/rubocop_challenger/pull/537) ryz310/dependabot/bundler/rubocop-rails-2.12.4 ([@ryz310](https://github.com/ryz310))
- [#542](https://github.com/ryz310/rubocop_challenger/pull/542) Bump addressable from 2.7.0 to 2.8.0 ([@ryz310](https://github.com/ryz310))
- [#543](https://github.com/ryz310/rubocop_challenger/pull/543) Bump rubocop-performance from 1.11.5 to 1.12.0 ([@ryz310](https://github.com/ryz310))
- [#546](https://github.com/ryz310/rubocop_challenger/pull/546) Bump yard from 0.9.26 to 0.9.27 ([@ryz310](https://github.com/ryz310))

## v2.3.0 (Feb 23, 2021)

### Feature

- [#465](https://github.com/ryz310/rubocop_challenger/pull/465) Add description whether the challenge is created by safe autocorrect or not ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#464](https://github.com/ryz310/rubocop_challenger/pull/464) Re-generate .rubocop_todo.yml with RuboCop v1.10.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#453](https://github.com/ryz310/rubocop_challenger/pull/453) ryz310/dependabot/bundler/thor-1.1.0 ([@ryz310](https://github.com/ryz310))
- [#457](https://github.com/ryz310/rubocop_challenger/pull/457) ryz310/dependabot/bundler/rubocop-1.9.1 ([@ryz310](https://github.com/ryz310))
- [#461](https://github.com/ryz310/rubocop_challenger/pull/461) Update ruby-orbs orb to v1.6.2 ([@ryz310](https://github.com/ryz310))

## v2.2.0 (Jan 11, 2021)

### Feature

- [#449](https://github.com/ryz310/rubocop_challenger/pull/449) Add verbose option ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#447](https://github.com/ryz310/rubocop_challenger/pull/447) ryz310/dependabot/bundler/rubocop-1.8.1 ([@ryz310](https://github.com/ryz310))

## v2.1.0 (Jan 11, 2021)

### Feature

- [#441](https://github.com/ryz310/rubocop_challenger/pull/441) Improve PR description generation ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#442](https://github.com/ryz310/rubocop_challenger/pull/442) Re-generate .rubocop_todo.yml with RuboCop v1.8.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#444](https://github.com/ryz310/rubocop_challenger/pull/444) Update simplecov requirement from = 0.17.1 to = 0.21.2 ([@ryz310](https://github.com/ryz310))

## v2.0.1 (Jan 06, 2021)

### Bugfix

- [#437](https://github.com/ryz310/rubocop_challenger/pull/437) Fix keyword argument expanding for Ruby 3.0 ([@ryz310](https://github.com/ryz310))

## v2.0.0 (Jan 04, 2021)

### Feature

- [#183](https://github.com/ryz310/rubocop_challenger/pull/183) Implement the flow that create a PR which re-generate ".rubocop_todo.yml" ([@ryz310](https://github.com/ryz310))
- [#187](https://github.com/ryz310/rubocop_challenger/pull/187) Bundle update rubocop ([@ryz310](https://github.com/ryz310))
- [#208](https://github.com/ryz310/rubocop_challenger/pull/208) Render links for release note and compare page ([@ryz310](https://github.com/ryz310))
- [#217](https://github.com/ryz310/rubocop_challenger/pull/217) Support auto gem config options ([@ryz310](https://github.com/ryz310))
- [#250](https://github.com/ryz310/rubocop_challenger/pull/250) Add error reporting feature ([@ryz310](https://github.com/ryz310))
- [#253](https://github.com/ryz310/rubocop_challenger/pull/253) Add information of the rubocop challenge ([@ryz310](https://github.com/ryz310))
- [#288](https://github.com/ryz310/rubocop_challenger/pull/288) Support ruby 2.7 ([@ryz310](https://github.com/ryz310))
- [#362](https://github.com/ryz310/rubocop_challenger/pull/362) Use rubocop auto correct all ([@ryz310](https://github.com/ryz310))
- [#398](https://github.com/ryz310/rubocop_challenger/pull/398) Add auto correct safe option ([@ryz310](https://github.com/ryz310))
- [#432](https://github.com/ryz310/rubocop_challenger/pull/432) Support ruby 3.0 ([@ryz310](https://github.com/ryz310))

### Bugfix

- [#212](https://github.com/ryz310/rubocop_challenger/pull/212) Fix the version of pr_comet ([@ryz310](https://github.com/ryz310))
- [#231](https://github.com/ryz310/rubocop_challenger/pull/231) Fix the way of requirements loading for optional dependencies ([@ryz310](https://github.com/ryz310))
- [#238](https://github.com/ryz310/rubocop_challenger/pull/238) Fix/load error of the updated gems ([@ryz310](https://github.com/ryz310))
- [#363](https://github.com/ryz310/rubocop_challenger/pull/363) Require rubocop-rails gem ([@ryz310](https://github.com/ryz310))

### Breaking Change

- [#180](https://github.com/ryz310/rubocop_challenger/pull/180) Farewell ruby 2.3 ([@ryz310](https://github.com/ryz310))
- [#184](https://github.com/ryz310/rubocop_challenger/pull/184) Remove base branch option ([@ryz310](https://github.com/ryz310))
- [#396](https://github.com/ryz310/rubocop_challenger/pull/396) End of support for Ruby 2.4 ([@ryz310](https://github.com/ryz310))

### Rubocop Challenge

- [#228](https://github.com/ryz310/rubocop_challenger/pull/228) Style/WordArray-20190625233039 ([@ryz310](https://github.com/ryz310))
- [#235](https://github.com/ryz310/rubocop_challenger/pull/235) Performance/RegexpMatch-20190729233033 ([@ryz310](https://github.com/ryz310))
- [#236](https://github.com/ryz310/rubocop_challenger/pull/236) Layout/SpaceAroundOperators-20190731233025 ([@ryz310](https://github.com/ryz310))
- [#317](https://github.com/ryz310/rubocop_challenger/pull/317) Performance/StartWith-20200523233027 ([@ryz310](https://github.com/ryz310))
- [#427](https://github.com/ryz310/rubocop_challenger/pull/427) Re-generate .rubocop_todo.yml with RuboCop v1.7.0 ([@ryz310](https://github.com/ryz310))

### Dependabot

- [#242](https://github.com/ryz310/rubocop_challenger/pull/242) ryz310/dependabot/bundler/rake-tw-13.0 ([@ryz310](https://github.com/ryz310))
- [#244](https://github.com/ryz310/rubocop_challenger/pull/244) ryz310/dependabot/bundler/simplecov-0.17.1 ([@ryz310](https://github.com/ryz310))
- [#245](https://github.com/ryz310/rubocop_challenger/pull/245) ryz310/dependabot/bundler/pr_comet-gte-0.2-and-lt-0.4 ([@ryz310](https://github.com/ryz310))
- [#271](https://github.com/ryz310/rubocop_challenger/pull/271) Bump thor from 1.0.0 to 1.0.1 ([@ryz310](https://github.com/ryz310))
- [#303](https://github.com/ryz310/rubocop_challenger/pull/303) ryz310/dependabot/bundler/pry-byebug-3.9.0 ([@ryz310](https://github.com/ryz310))
- [#376](https://github.com/ryz310/rubocop_challenger/pull/376) ryz310/dependabot/bundler/rspec-3.10.0 ([@ryz310](https://github.com/ryz310))
- [#414](https://github.com/ryz310/rubocop_challenger/pull/414) ryz310/dependabot/bundler/rubocop-rspec-2.0.1 ([@ryz310](https://github.com/ryz310))
- [#421](https://github.com/ryz310/rubocop_challenger/pull/421) ryz310/dependabot/bundler/rubocop-1.6.1 ([@ryz310](https://github.com/ryz310))
- [#423](https://github.com/ryz310/rubocop_challenger/pull/423) ryz310/dependabot/bundler/rubocop-rails-2.9.1 ([@ryz310](https://github.com/ryz310))
- [#426](https://github.com/ryz310/rubocop_challenger/pull/426) ryz310/dependabot/bundler/rake-13.0.3 ([@ryz310](https://github.com/ryz310))
- [#428](https://github.com/ryz310/rubocop_challenger/pull/428) ryz310/dependabot/bundler/yard-0.9.26 ([@ryz310](https://github.com/ryz310))
- [#431](https://github.com/ryz310/rubocop_challenger/pull/431) ryz310/dependabot/bundler/rubocop-performance-1.9.2 ([@ryz310](https://github.com/ryz310))

### Security

- [#230](https://github.com/ryz310/rubocop_challenger/pull/230) Bump yard from 0.9.19 to 0.9.20 ([@ryz310](https://github.com/ryz310))

### Misc

- [#178](https://github.com/ryz310/rubocop_challenger/pull/178) Use #abort instead of #puts and #exit! ([@ryz310](https://github.com/ryz310))
- [#181](https://github.com/ryz310/rubocop_challenger/pull/181) Remove waffle.io badge ([@ryz310](https://github.com/ryz310))
- [#185](https://github.com/ryz310/rubocop_challenger/pull/185) Improve code coverage and fix implements ([@ryz310](https://github.com/ryz310))
- [#186](https://github.com/ryz310/rubocop_challenger/pull/186) Use #abort instead of #exit! ([@ryz310](https://github.com/ryz310))
- [#192](https://github.com/ryz310/rubocop_challenger/pull/192) Extract with pr comet ([@ryz310](https://github.com/ryz310))
- [#216](https://github.com/ryz310/rubocop_challenger/pull/216) Use rainbow gem ([@ryz310](https://github.com/ryz310))
- [#218](https://github.com/ryz310/rubocop_challenger/pull/218) Add pull request to GitHub project on execute ([@ryz310](https://github.com/ryz310))
- [#219](https://github.com/ryz310/rubocop_challenger/pull/219) Add auto updating target gems ([@ryz310](https://github.com/ryz310))
- [#223](https://github.com/ryz310/rubocop_challenger/pull/223) Support base branch option ([@ryz310](https://github.com/ryz310))
- [#227](https://github.com/ryz310/rubocop_challenger/pull/227) Migrate circle ci version to 2.1 ([@ryz310](https://github.com/ryz310))
- [#239](https://github.com/ryz310/rubocop_challenger/pull/239) Introduce gem comet ([@ryz310](https://github.com/ryz310))
- [#294](https://github.com/ryz310/rubocop_challenger/pull/294) Update ruby-orbs orb to v1.6.0 ([@ryz310](https://github.com/ryz310))
- [#304](https://github.com/ryz310/rubocop_challenger/pull/304) Edit dependabot configuration ([@ryz310](https://github.com/ryz310))
- [#433](https://github.com/ryz310/rubocop_challenger/pull/433) Update `pr_comet` ([@ryz310](https://github.com/ryz310))

## v1.2.0 (Feb 27, 2019)

### Feature

- Challenge incompleted list ([#170](https://github.com/ryz310/rubocop_challenger/pull/170))

### Bugfix

- Fix exit code when no more auto-correctable rule ([#175](https://github.com/ryz310/rubocop_challenger/pull/175))

### Breaking Change

- Remove "regenerate-rubocop-todo" option ([#170](https://github.com/ryz310/rubocop_challenger/pull/170))

## v1.1.2 (Feb 21, 2019)

### Feature

- Re-generate .rubocop_todo.yml on pre-challenge ([#169](https://github.com/ryz310/rubocop_challenger/pull/169))

## v1.1.1 (Jan 17, 2019)

### Bugfix

- Fix encountering name error when finding a cop class by cop name ([#164](https://github.com/ryz310/rubocop_challenger/pull/164))

### Misc

- Configure Renovate ([#162](https://github.com/ryz310/rubocop_challenger/pull/162))

## v1.1.0 (Dec 29, 2018)

### Feature

- Support ruby 2.6 ([#156](https://github.com/ryz310/rubocop_challenger/pull/156))

### Misc

- Change emoji on the commit message ([#158](https://github.com/ryz310/rubocop_challenger/pull/158))

## v1.0.0 (Dec 3, 2018)

Release v1.0.0 :tada:

## v1.0.0.pre4 (Nov 26, 2018)

### Security

- Add quiet option on git push command ([#149](https://github.com/ryz310/rubocop_challenger/pull/149))

### Misc

- Add yard testing flow ([#150](https://github.com/ryz310/rubocop_challenger/pull/150))
- Add jailbreak script ([#151](https://github.com/ryz310/rubocop_challenger/pull/151))

## v1.0.0.pre3 (Nov 17, 2018)

### Feature

- Output the result in the execution ([#139](https://github.com/ryz310/rubocop_challenger/pull/139))
- Colorize error log ([#145](https://github.com/ryz310/rubocop_challenger/pull/145))

### Bugfix

- Filter access token in the command logging ([#144](https://github.com/ryz310/rubocop_challenger/pull/144))

## v1.0.0.pre2 (Nov 15, 2018)

### Feature

- Support private repository ([#132](https://github.com/ryz310/rubocop_challenger/pull/132))
- Support old git version ([#133](https://github.com/ryz310/rubocop_challenger/pull/133))

### Misc

- Add Github::Client#add_labels spec ([#131](https://github.com/ryz310/rubocop_challenger/pull/131))
- Remove a unnecessary option ([#134](https://github.com/ryz310/rubocop_challenger/pull/134))

## v1.0.0.pre (Nov 13, 2018)

### Feature

- Use octokit ([#121](https://github.com/ryz310/rubocop_challenger/pull/121))

### Breaking Change

- Change `--regenerate-rubocop-todo` option default value to true

### Misc

- Modify gem version validator ([#127](https://github.com/ryz310/rubocop_challenger/pull/127))

## v0.5.2 (Nov 4, 2018)

### Misc

- Install code climate ([#116](https://github.com/ryz310/rubocop_challenger/pull/116))
- Fix coveralls badge URL ([#117](https://github.com/ryz310/rubocop_challenger/pull/117))
- Uninstall coveralls ([#118](https://github.com/ryz310/rubocop_challenger/pull/118))

## v0.5.1 (Nov 1, 2018)

### Misc

- Style/MutableConstant at Tue Oct 30 23:30:33 UTC 2018 ([#106](https://github.com/ryz310/rubocop_challenger/pull/106))
- Install coveralls ([#107](https://github.com/ryz310/rubocop_challenger/pull/107))
- Definition of Metrics/BlockLength ([#109](https://github.com/ryz310/rubocop_challenger/pull/109))
- Fix offense of RSpec/ExampleLength ([#110](https://github.com/ryz310/rubocop_challenger/pull/110))
- Fix offense of Style/Documentation ([#111](https://github.com/ryz310/rubocop_challenger/pull/111))
- Fix offense of Metrics/LineLength ([#112](https://github.com/ryz310/rubocop_challenger/pull/112))
- Fix that testing target is wrong ([#113](https://github.com/ryz310/rubocop_challenger/pull/113))

## v0.5.0 (Oct 30, 2018)

### Feature

- Use bundle exec ([#100](https://github.com/ryz310/rubocop_challenger/pull/100))

### Breaking Change

- Return example name ([#101](https://github.com/ryz310/rubocop_challenger/pull/101))

### Misc

- Layout/AlignHash at Sun Oct 28 23:30:20 UTC 2018 ([#97](https://github.com/ryz310/rubocop_challenger/pull/97))
- Add Rubocop Challenge example to the README.md ([#98](https://github.com/ryz310/rubocop_challenger/pull/98))
- Update bundle when create release PR ([#103](https://github.com/ryz310/rubocop_challenger/pull/103))

## v0.4.1 (Oct 28, 2018)

### Bugfix

- Return status code 0 when exists no auto-correctable cop ([#91](https://github.com/ryz310/rubocop_challenger/pull/91))
- Fix rubocop version mismatch ([#92](https://github.com/ryz310/rubocop_challenger/pull/92))

### Misc

- Style/RedundantSelf at Fri Oct 26 05:58:13 UTC 2018 ([#89](https://github.com/ryz310/rubocop_challenger/pull/89))
- Layout/SpaceInsideBlockBraces at Sat Oct 27 23:30:21 UTC 2018 ([#93](https://github.com/ryz310/rubocop_challenger/pull/93))

## v0.4.0 (Oct 26, 2018)

### Feature

- Generate document from yardoc ([#86](https://github.com/ryz310/rubocop_challenger/pull/86))

### Misc

- Rake/create pr for version up ([#81](https://github.com/ryz310/rubocop_challenger/pull/81))
- Style/RescueModifier at Wed Oct 24 23:30:21 UTC 2018 ([#82](https://github.com/ryz310/rubocop_challenger/pull/82))

## v0.3.1 (Oct 23, 2018)

### Feature

- Modify default template ([#73](https://github.com/ryz310/rubocop_challenger/pull/73))

## v0.3.0 (Oct 23, 2018)

### Feature

- Add labels option ([#67](https://github.com/ryz310/rubocop_challenger/pull/67))
- Add template option ([#70](https://github.com/ryz310/rubocop_challenger/pull/70))

### Misc

- Run rubocop challenge after release ([#68](https://github.com/ryz310/rubocop_challenger/pull/68))

## v0.2.1 (Oct 23, 2019)

### Bugfix

- Fix default PR template file path ([#64](https://github.com/ryz310/rubocop_challenger/pull/64))

## v0.2.0 (Oct 23, 2018)

### Feature

- Generate pr template ([#50](https://github.com/ryz310/rubocop_challenger/pull/50))
- Add no-commit option ([#53](https://github.com/ryz310/rubocop_challenger/pull/53))
- Return status code 1 when an error occurs ([#56](https://github.com/ryz310/rubocop_challenger/pull/56))
- Add option which regenerate rubocop todo file ([#59](https://github.com/ryz310/rubocop_challenger/pull/59))

### Misc

- Add access token description ([#48](https://github.com/ryz310/rubocop_challenger/pull/48))
- Add no document option to gem install command ([#51](https://github.com/ryz310/rubocop_challenger/pull/51))

## v0.1.3 (Oct 21, 2018)

### Misc

- Style/TrailingCommaInArrayLiteral at Fri Oct 19 23:30:18 UTC 2018 ([#34](https://github.com/ryz310/rubocop_challenger/pull/34))
- Update readme ([#36](https://github.com/ryz310/rubocop_challenger/pull/36))
- Add challenge class spec ([#42](https://github.com/ryz310/rubocop_challenger/pull/42))

## v0.1.2 (Oct 19, 2018)

### Misc

- Install from gem ([#28](https://github.com/ryz310/rubocop_challenger/pull/28))

## v0.1.1 (Oct 19, 2018)

Minor fixes

## v0.1.0 (Oct 18, 2018)

Initial release! :rocket:
