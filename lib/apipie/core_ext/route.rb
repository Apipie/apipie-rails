begin
  # Rails 4
  ActionDispatch::Journey
rescue NameError
  # Rails 3
  require 'journey'
  Journey
end::Route.class_eval do
  attr_accessor :base_url
end
