require 'active_support/dependencies'
require 'rdoc'
require 'rdoc/markup/to_html'

# add path to restapi controller to ActiveSupport paths
%w{ controllers views }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

require "restapi/routing"
require "restapi/restapi_module"
require "restapi/method_description"
require "restapi/resource_description"
require "restapi/param_description"
require "restapi/error_description"
require "restapi/validator"
require "restapi/dsl_definition"
require "restapi/railtie"
require "restapi/version"