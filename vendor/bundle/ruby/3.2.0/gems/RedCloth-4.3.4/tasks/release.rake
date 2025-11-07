namespace :release do
  desc 'Push all gems to rubygems.org'
  # 1. run rake test
  # 2. update changelog
  # 3. change version in version.rb
  # 4. branch into stable vx.x branch
  # 5. git tag and push tag
  # 5.1. git tag vx.x.x
  # 5.2. git push --follow-tags

  task :gem do
    sh("gem build redcloth.gemspec")
    sh("gem push RedCloth-*.gem")
  end
end
