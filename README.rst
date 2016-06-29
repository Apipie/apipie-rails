========================
 API Documentation Tool
========================

.. image:: https://travis-ci.org/Apipie/apipie-rails.svg?branch=master
    :target: https://travis-ci.org/Apipie/apipie-rails
.. image:: https://codeclimate.com/github/Apipie/apipie-rails.svg
    :target: https://codeclimate.com/github/Apipie/apipie-rails
.. image:: https://badges.gitter.im/Apipie/apipie-rails.svg
   :alt: Join the chat at https://gitter.im/Apipie/apipie-rails
   :target: https://gitter.im/Apipie/apipie-rails?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
.. image:: https://img.shields.io/gem/v/apipie-rails.svg
   :alt: Latest release
   :target: https://rubygems.org/gems/apipie-rails

Apipie-rails is a DSL and Rails engine for documenting your RESTful
API. Instead of traditional use of ``#comments``, Apipie lets you
describe the code, through the code. This brings advantages like:

* No need to learn yet another syntax, you already know Ruby, right?
* Possibility of reusing the docs for other purposes (such as validation)
* Easier to extend and maintain (no string parsing involved)
* Possibility of reusing other sources for documentation purposes (such as
  routes etc.)

The documentation is available from within your app (by default under the
``/apipie`` path.) In development mode, you can see the changes as you
go. It's markup language agnostic, and even provides an API for reusing
the documentation data in JSON.

Getting started
---------------

The easiest way to get Apipie up and running with your app is:

.. code:: sh

   echo "gem 'apipie-rails'" >> Gemfile
   bundle install
   rails g apipie:install

Now you can start documenting your resources and actions (see
`DSL Reference`_ for more info):

.. code:: ruby

   api :GET, '/users/:id'
   param :id, :number
   def show
     # ...
   end


Run your application and see the result at
``http://localhost:3000/apipie``. For further processing, you can
use ``http://localhost:3000/apipie.json``.

For a more comprehensive getting started guide, see
`this demo <https://github.com/iNecas/apipie-demo>`_, which includes
features such as generating documentation from tests, recording examples etc.

Screenshots
-----------

.. image:: https://github.com/Apipie/apipie-rails/blob/master/images/screenshot-1.png
.. image:: https://github.com/Apipie/apipie-rails/blob/master/images/screenshot-2.png

Authors
-------

`Pajk <https://github.com/Pajk>`_ and `iNecas <https://github.com/iNecas>`_

Contributors
------------

See `Contributors page  <https://github.com/Apipie/apipie-rails/graphs/contributors>`_. Special thanks to all of them!

License
-------

Apipie-rails is released under the `MIT License <http://opensource.org/licenses/MIT>`_

===============
 Documentation
===============

.. contents:: `Table Of Contents`
  :depth: 2

===============
 DSL Reference
===============

Resource Description
--------------------

You can describe a resource on the controller level. The description is introduced by calling
``resource_description do ... end``.

Inheritance is supported, so you can specify common params for group of controllers in their parent
class.

The following keywords are available (all are optional):

resource_id
  How the resource will be referenced in Apipie (paths, ``see`` command etc.); by default `controller_name.downcase` is used.

name
  Human readable name of resource. By default ``class.name.humanize`` is used.

short (also short_description)
  Short description of the resource (it's shown on both the list of resources, and resource details)

desc (also description and full_description)
  Full description of the resource (shown only in resource details)

param
  Common params for all methods defined in controller/child controllers.

api_base_url
  What URL is the resource available under.

api_versions (also api_version)
  What versions does the controller define the resource. (See `Versioning`_ for details.)

formats
  Request / response formats.

error
  Describe every possible error that can happen when calling all
  methods defined in controller. HTTP response code and description can be provided.

app_info
  In case of versioning, this sets app info description on a per_version basis.

meta
  Hash or array with custom metadata.

Example:
~~~~~~~~

.. code:: ruby

   resource_description do
     short 'Site members'
     formats ['json']
     param :id, Fixnum, :desc => "User ID", :required => false
     param :resource_param, Hash, :desc => 'Param description for all methods' do
       param :ausername, String, :desc => "Username for login", :required => true
       param :apassword, String, :desc => "Password for login", :required => true
     end
     api_version "development"
     error 404, "Missing"
     error 500, "Server crashed for some <%= reason %>", :meta => {:anything => "you can think of"}
     error :unprocessable_entity, "Could not save the entity."
     meta :author => {:name => 'John', :surname => 'Doe'}
     description <<-EOS
       == Long description
        Example resource for rest api documentation
        These can now be accessed in <tt>shared/header</tt> with:
          Headline: <%= headline %>
          First name: <%= person.first_name %>

        If you need to find out whether a certain local variable has been
        assigned a value in a particular render call, you need to use the
        following pattern:

        <% if local_assigns.has_key? :headline %>
           Headline: <%= headline %>
        <% end %>

       Testing using <tt>defined? headline</tt> will not work. This is an
       implementation restriction.

       === Template caching

       By default, Rails will compile each template to a method in order
       to render it. When you alter a template, Rails will check the
       file's modification time and recompile it in development mode.
     EOS
   end


Method Description
------------------

Then describe methods available to your API.

api
  Describe how this method is exposed, and provide a short description.
  The first parameter is HTTP method (one of :GET/:POST/:PUT/:DELETE).
  The second parameter is the relative URL path which is mapped to this
  method. The last parameter is the methods short description.
  You can use this +api+ method more than once per method. It could
  be useful when there are more routes mapped to it.

  When providing just one argument (description), or no argument at all,
  the paths will be loaded from the routes.rb file.

api!
  Provide a short description and additional option.
  The last parameter is the methods short description.
  The paths will be loaded from routes.rb file. See
  `Rails Routes Integration`_ for more details.

api_versions (also api_version)
  What version(s) does the action belong to. (See `Versioning`_ for details.)

param
  Look at Parameter description section for details.

formats
  Method level request / response formats.

error
  Describe each possible error that can happen while calling this
  method. HTTP response code and description can be provided.

description
  Full method description, which will be converted into HTML by the
  chosen markup language processor.

example
  Provide an example of the server response; whole communication or response type.
  It will be formatted as code.

see
  Provide reference to another method, this has to be a string with
  controller_name#method_name.

meta
  Hash or array with custom metadata.

show
  Resource is hidden from documentation when set to false (true by default)

Example:
~~~~~~~~

.. code:: ruby

   # The simplest case: just load the paths from routes.rb
   api!
   def index
   end

   # More complex example
   api :GET, "/users/:id", "Show user profile"
   show false
   error :code => 401, :desc => "Unauthorized"
   error :code => 404, :desc => "Not Found", :meta => {:anything => "you can think of"}
   param :session, String, :desc => "user is logged in", :required => true
   param :regexp_param, /^[0-9]* years/, :desc => "regexp param"
   param :array_param, [100, "one", "two", 1, 2], :desc => "array validator"
   param :boolean_param, [true, false], :desc => "array validator with boolean"
   param :proc_param, lambda { |val|
     val == "param value" ? true : "The only good value is 'param value'."
   }, :desc => "proc validator"
   param :param_with_metadata, String, :desc => "", :meta => [:your, :custom, :metadata]
   description "method description"
   formats ['json', 'jsonp', 'xml']
   meta :message => "Some very important info"
   example " 'user': {...} "
   see "users#showme", "link description"
   see :link => "users#update", :desc => "another link description"
   def show
     #...
   end


Parameter Description
---------------------

Use ``param`` to describe every possible parameter. You can use the Hash validator
in conjunction with a block given to the param method to describe nested parameters.

name
  The first argument is the parameter name as a symbol.

validator
  Second parameter is the parameter validator, choose one from section `Validators`_

desc
  Parameter description.

required
  Set this true/false to make it required/optional. Default is optional

allow_nil
  Setting this to true means that ``nil`` can be passed.

allow_blank
  Like ``allow_nil``, but for blank values. ``false``, ``""``, ``' '``, ``nil``, ``[]``, and ``{}`` are all blank.

as
  Used by the processing functionality to change the name of a key params.

meta
  Hash or array with custom metadata.

show
  Parameter is hidden from documentation when set to false (true by default)

missing_message
  Specify the message to be returned if the parameter is missing as a string or Proc.
  Defaults to ``Missing parameter #{name}`` if not specified.

Example:
~~~~~~~~

.. code:: ruby

   param :user, Hash, :desc => "User info" do
     param :username, String, :desc => "Username for login", :required => true
     param :password, String, :desc => "Password for login", :required => true
     param :membership, ["standard","premium"], :desc => "User membership"
     param :admin_override, String, :desc => "Not shown in documentation", :show => false
     param :ip_address, String, :desc => "IP address", :required => true, :missing_message => lambda { I18n.t("ip_address.required") }
   end
   def create
     #...
   end

DRY with param_group
--------------------

Often, params occur together in more actions. Typically, most of the
params for ``create`` and ``update`` actions are shared between them.

These params can be extracted with ``def_param_group`` and
``param_group`` keywords.

The definition is looked up in the scope of the controller. If the
group is defined in a different controller, it might be referenced by
specifying the second argument.

Example:
~~~~~~~~

.. code:: ruby

   # v1/users_controller.rb
   def_param_group :address do
     param :street, String
     param :number, Integer
     param :zip, String
   end

   def_param_group :user do
     param :user, Hash do
       param :name, String, "Name of the user"
       param_group :address
     end
   end

   api :POST, "/users", "Create an user"
   param_group :user
   def create
     # ...
   end

   api :PUT, "/users/:id", "Update an user"
   param_group :user
   def update
     # ...
   end

   # v2/users_controller.rb
   api :POST, "/users", "Create an user"
   param_group :user, V1::UsersController
   def create
     # ...
   end

Action Aware params
-------------------

In CRUD operations, this pattern occurs quite often - params that need
to be set are:

* for create action: ``required => true`` and ``allow_nil => false``
* for update action: ``required => false`` and ``allow_nil => false``

This makes it hard to share the param definitions across theses
actions. Therefore, you can make the description a bit smarter by
setting ``:action_aware => true``.

You can specify explicitly how the param group should be evaluated
with ``:as`` option (either :create  or :update)

Example
~~~~~~~

.. code:: ruby

   def_param_group :user do
     param :user, Hash, :action_aware => true do
       param :name, String, :required => true
       param :description, String
     end
   end

   api :POST, "/users", "Create an user"
   param_group :user
   def create
     # ...
   end

   api :PUT, "/users/admin", "Create an admin"
   param_group :user, :as => :create
   def create_admin
     # ...
   end

   api :PUT, "/users/:id", "Update an user"
   param_group :user
   def update
     # ...
   end

In this case, ``user[name]`` will be not be allowed nil for all
actions and required only for ``create`` and ``create_admin``. Params
with ``allow_nil`` set explicitly don't have this value changed.

Action awareness is inherited from ancestors (in terms of
nested params).

Concerns
--------

Sometimes, the actions are not defined in the controller class
directly but included from a module instead. You can load the Apipie
DSL into the module by extending it with ``Apipie::DSL::Concern``.

The module can be used in more controllers. Therefore there is a way to
substitute parts of the documentation in the module with controller
specific values. These substitutions can be stated explicitly with
``apipie_concern_subst(:key => "value")`` (needs to be called before
the module is included to take effect). The substitutions are
performed in the paths and descriptions of APIs and names and descriptions
of params.

There are some default substitutions available:

:controller_path
  value of ``controller.controller_path``, e.g. ``api/users`` for
  ``Api::UsersController``. Only if not using the ``api!`` keyword.

:resource_id
  Apipie identifier of the resource, e.g. ``users`` for
  ``Api::UsersController`` or set by ``resource_id``

Example
~~~~~~~

.. code:: ruby

   # users_module.rb
   module UsersModule
     extend Apipie::DSL::Concern

     api :GET, '/:controller_path', 'List :resource_id'
     def index
       # ...
     end

     api! 'Show a :resource'
     def show
       # ...
     end

     api :POST, '/:resource_id', "Create a :resource"
     param :concern, Hash, :required => true
       param :name, String, 'Name of a :resource'
       param :resource_type, ['standard','vip']
     end
     def create
       # ...
     end

     api :GET, '/:resource_id/:custom_subst'
     def custom
       # ...
     end
   end

   # users_controller.rb
   class UsersController < ApplicationController

     resource_description { resource_id 'customers' }

     apipie_concern_subst(:custom_subst => 'custom', :resource => 'customer')
     include UsersModule

     # the following paths are documented
     # api :GET, '/users'
     # api :GET, '/customers/:id', 'Show a customer'
     # api :POST, '/customers', 'Create a customer'
     #   param :customer, :required => true do
     #     param :name, String, 'Name of a customer'
     #     param :customer_type, ['standard', 'vip']
     #   end
     # api :GET, '/customers/:custom'
   end



=========================
 Configuration Reference
=========================

Create a configuration file in e.g. ``/config/initializers/apipie.rb``.
You can set the application name, footer text, API and documentation base URL
and turn off validations. You can also choose your favorite markup language
for full descriptions.

app_name
  Name of your application; used in breadcrumbs navigation.

copyright
  Copyright information (shown in page footer).

doc_base_url
  Documentation frontend base url.

api_base_url
  Base url for default version of your API. To set it for specific version use ``config.api_base_url[version] = url``.

default_version
  Default API version to be used (1.0 by default)

validate
  Parameters validation is turned off when set to false. When set to
  ``:explicitly``, you must invoke parameter validation yourself by calling
  controller method ``apipie_validations`` (typically in a before_action).
  When set to ``:implicitly`` (or just true), your controller's action
  methods are wrapped with generated methods which call ``apipie_validations``,
  and then call the action method. (``:implicitly`` by default)

validate_value
  Check the value of params against specified validators (true by
  default)

validate_presence
  Check the params presence against the documentation.

validate_key
  Check the received params to ensure they are defined in the API. (false by default)

process_params
  Process and extract the parameter defined from the params of the request
  to the api_params variable

app_info
  Application long description.

reload_controllers
  Set to enable/disable reloading controllers (and the documentation with it). Enabled by default in development.

api_controllers_matcher
  For reloading to work properly you need to specify where your API controllers are. Can be an array if multiple paths are needed

api_routes
  Set if your application uses a custom API router, different from the Rails
  default

routes_formatter
  An object providing the translation from the Rails routes to the
  format usable in the documentation when using the `api!` keyword. By
  default, the ``Apipie::RoutesFormatter`` is used.

markup
  You can choose markup language for descriptions of your application,
  resources and methods. RDoc is the default but you can choose from
  Apipie::Markup::Markdown.new or Apipie::Markup::Textile.new.
  In order to use Markdown you need Maruku gem and for Textile you
  need RedCloth. Add those to your gemfile and run bundle if you
  want to use them. You can also add any other markup language
  processor.

layout
  Name of a layout template to use instead of Apipie's layout. You can use
  Apipie.include_stylesheets and Apipie.include_javascripts helpers to include
  Apipie's stylesheets and javascripts.

ignored
  An array of controller names (strings) (might include actions as well)
  to be ignored when generationg the documentation
  e.g. ``%w[Api::CommentsController Api::PostsController#post]``

namespaced_resources
  Use controller paths instead of controller names as resource id.
  This prevents same named controllers overwriting each other.

authenticate
  Pass a proc in order to authenticate user. Pass nil for
  no authentication (by default).

authorize
  Pass a proc in order to authorize controllers and methods. The Proc is evaluated in the controller context.

show_all_examples
  Set this to true to set show_in_doc=1 in all recorded examples

link_extension
  The extension to use for API pages ('.html' by default). Link extensions
  in static API docs cannot be changed from '.html'.

languages
  List of languages the API documentation should be translated into. Empty by default.

default_locale
  Locale used for generating documentation when no specific locale is set.
  Set to 'en' by default.

locale
  Pass locale setter/getter

.. code:: ruby

    config.locale = lambda { |loc| loc ? FastGettext.set_locale(loc) : FastGettext.locale }

translate
  Pass proc to translate strings using the localization library your project uses.
  For example see `Localization`_

Example:

.. code:: ruby

   Apipie.configure do |config|
     config.app_name = "Test app"
     config.copyright = "&copy; 2012 Pavel Pokorny"
     config.doc_base_url = "/apidoc"
     config.api_base_url = "/api"
     config.validate = false
     config.markup = Apipie::Markup::Markdown.new
     config.reload_controllers = Rails.env.development?
     config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
     config.api_routes = Rails.application.routes
     config.app_info["1.0"] = "
       This is where you can inform user about your application and API
       in general.
     "
     config.authenticate = Proc.new do
        authenticate_or_request_with_http_basic do |username, password|
          username == "test" && password == "supersecretpassword"
       end
     end
     config.authorize = Proc.new do |controller, method, doc|
       !method   # show all controller doc, but no method docs.
     end
   end

checksum_path
  Used in ChecksumInHeaders middleware (see `JSON checksums`_ for more info). It contains path prefix(es) where the header with checksum is added. If set to nil, checksum is added in headers in every response. e.g. ``%w[/api /apipie]``

update_checksum
  If set to true, the checksum is recalculated with every documentation_reload call

========================
Rails Routes Integration
========================

Apipie is able to load the information about the paths based on the
routes defined in the Rails application, by using the `api!` keyword
in the DSL.

It should be usable out of box, however, one might want
to do some customization (such as omitting some implicit parameters in
the path etc.). For this kind of customizations one can create a new
formatter and pass as the ``Apipie.configuration.routes_formatter``
option, like this:

.. code:: ruby

   class MyFormatter < Apipie::RoutesFormatter
     def format_path(route)
       super.gsub(/\(.*?\)/, '').gsub('//','') # hide all implicit parameters
     end
   end

   Apipie.configure do |config|
    ...
    config.routes_formatter = MyFormatter.new
    ...
   end

A similar way can be used to influence things like order, or a description
of the loaded APIs, even omitting some paths if needed.

============
 Processing
============

The goal is to extract and pre-process parameters of the request.

For example Rails, by default, transforms an empty array to nil value. Perhaps
you want to transform it again into an empty array. Or you
want to support an enumeration type (comma separated values) and
you want to automatically transform this string into an array.

To use it, set the ``process_params`` configuration variable to true.

Also by using ``as`` you can separate your API parameter
names from the names you are using inside your code.

To implement it, you just have to write a process_value
function in your validator:

For an enumeration type:

.. code:: ruby

   def process_value(value)
    value ? value.split(',') : []
   end

============
 Validators
============

Every parameter needs to have an associated validator. For now there are some
basic validators. You can always provide your own to achieve complex
results.

If validations are enabled (default state) the parameters of every
request are validated. If the value is wrong an +ArgumentError+ exception
is raised and can be rescued and processed. It contains a description
of the parameter value expectations. Validations can be turned off
in the configuration file.

Parameter validation normally happens after before_actions, just before
your controller method is invoked. If you prefer to control when parameter
validation occurs, set the configuration parameter ``validate`` to ``:explicitly``.
You must then call the ``apipie_validations`` method yourself, e.g.:

.. code:: ruby

   before_action: :apipie_validations

This is useful if you have before_actions which use parameter values: just add them
after the ``apipie_validations`` before_action.

TypeValidator
-------------
Check the parameter type. Only String, Hash and Array are supported
for the sake of simplicity. Read more to find out how to add
your own validator.

.. code:: ruby

   param :session, String, :desc => "user is logged in", :required => true
   param :facts, Hash, :desc => "Additional optional facts about the user"


RegexpValidator
---------------
Check parameter value against given regular expression.

.. code:: ruby

   param :regexp_param, /^[0-9]* years/, :desc => "regexp param"


EnumValidator
--------------

Check if parameter value is included in the given array.

.. code:: ruby

   param :enum_param, [100, "one", "two", 1, 2], :desc => "enum validator"


ProcValidator
-------------

If you need more complex validation and you know you won't reuse it, you
can use the Proc/lambda validator. Provide your own Proc, taking the value
of the parameter as the only argument. Return true if value passes validation
or return some text about what is wrong otherwise. _Don't use the keyword *return*
if you provide an instance of Proc (with lambda it is ok), just use the last
statement return property of ruby.

.. code:: ruby

   param :proc_param, lambda { |val|
     val == "param value" ? true : "The only good value is 'param value'."
   }, :desc => "proc validator"


HashValidator
-------------

You can describe hash parameters in depth if you provide a block with a
description of nested values.

.. code:: ruby

   param :user, Hash, :desc => "User info" do
     param :username, String, :desc => "Username for login", :required => true
     param :password, String, :desc => "Password for login", :required => true
     param :membership, ["standard","premium"], :desc => "User membership"
   end


NilValidator
------------

In fact there isn't any NilValidator, but setting it to nil can be used to
override parameters described on the resource level.

.. code:: ruby

   param :user, nil
   def destroy
     #...
   end

ArrayValidator
--------------

Check if the parameter is an array

Additional options
~~~~~~~~~~~~~~~~~

of
  Specify the type of items. If not given it accepts an array of any item type

in
  Specify an array of valid item values.

Examples
~~~~~~~~

Assert `things` is an array of any items

.. code:: ruby

  param :things, Array

Assert `hits` must be an array of integer values

.. code:: ruby

  param :hits, Array, of: Integer

Assert `colors` must be an array of valid string values

.. code:: ruby

  param :colors, Array, in: ["red", "green", "blue"]


The retrieving of valid items can be deferred until needed using a lambda. It is evaluated only once

.. code:: ruby

  param :colors, Array, in: ->  { Color.all.pluck(:name) }


NestedValidator
-------------

You can describe nested parameters in depth if you provide a block with a
description of nested values.

.. code:: ruby

   param :comments, Array, :desc => "User comments" do
     param :name, String, :desc => "Name of the comment", :required => true
     param :comment, String, :desc => "Full comment", :required => true
   end



Adding custom validator
-----------------------

Only basic validators are included but it is really easy to add your own.
Create a new initializer with a subclass of Apipie::Validator::BaseValidator.
Two methods are required to implement this - instance method
:code:`validate(value)` and class method
:code:`build(param_description, argument, options, block)`.

When searching for the validator +build+ method, every subclass of
Apipie::Validator::BaseValidator is called. The first one that returns the
constructed validator object is used.

Example: Adding IntegerValidator

We want to check if the parameter value is an integer like this:

.. code:: ruby

   param :id, Integer, :desc => "Company ID"

So we create apipie_validators.rb initializer with this content:

.. code:: ruby

   class IntegerValidator < Apipie::Validator::BaseValidator

     def initialize(param_description, argument)
       super(param_description)
       @type = argument
     end

     def validate(value)
       return false if value.nil?
       !!(value.to_s =~ /^[-+]?[0-9]+$/)
     end

     def self.build(param_description, argument, options, block)
       if argument == Integer || argument == Fixnum
         self.new(param_description, argument)
       end
     end

     def description
       "Must be #{@type}."
     end
   end

Parameters of the build method:

param_description
  Instance of Apipie::ParamDescription contains all
  given information about the validated parameter.

argument
  Specified validator; in our example it is +Integer+

options
  Hash with specified options, for us just ``{:desc => "Company ID"}``

block
  Block converted into Proc, use it as you desire. In this example nil.


============
 Versioning
============

Every resource/method can belong to one or more versions. The version is
specified with the `api_version` DSL keyword. When not specified,
the resource belongs to `config.default_version` ("1.0" by default)

.. code:: ruby

   resource_description do
     api_versions "1", "2"
   end

   api :GET, "/api/users/", "List: users"
   api_version "1"
   def index
     # ...
   end

   api :GET, "/api/users/", "List: users", :deprecated => true

In the example above we say the whole controller/resource is defined
for versions "1" and "2", but we override this by explicitly saying
`index` belongs only to version "1". Also, inheritance works (therefore
we can specify the api_version for the parent controller, and all
children will know about that). Routes can be flagged as deprecated,
and an annotation will be added to them when viewing in the API
documentation.

From the Apipie API perspective, the resources belong to the version.
With versioning, there are paths like this provided by apipie:

.. code::

   /apipie/1/users/index
   /apipie/2/users/index

When not specifying the version explicitly in the path (or in DSL),
default version (`Apipie.configuration.default_version`) is used
instead ("1.0" by default). Therefore, an application that doesn't
need versioning should work as before.

The static page generator takes a version parameter (or uses default).

You can specify the versions for the examples, with the `versions`
keyword. It specifies the versions the example is used for. When not
specified, it's shown in all versions with the given method.

When referencing or quering the resource/method descripion, this
format should be used: "version#resource#method". When not specified,
the default version is used instead.


========
 Markup
========

The default markup language is `RDoc
<http://rdoc.rubyforge.org/RDoc/Markup.html>`_. It can be changed in
the config file (``config.markup=``) to one of these:

Markdown
  Use Apipie::Markup::Markdown.new. You need Maruku gem.

Textile
  Use Apipie::Markup::Textile.new. You need RedCloth gem.

Or provide you own object with a ``to_html(text)`` method.
For inspiration, this is how Textile markup usage is implemented:

.. code:: ruby

   class Textile
     def initialize
       require 'RedCloth'
     end
     def to_html(text)
       RedCloth.new(text).to_html
     end
   end

============
Localization
============

Apipie has support for localized API documentation in both formats (JSON and HTML).
Apipie uses the library I18n for localization of itself.
Check ``config/locales`` directory for available translations.

A major part of strings in the documentation comes from the API.
As preferences regarding localization libraries differ amongst project, Apipie needs to know how to set the locale for your project,
and how to translate a string using the library your project uses. That can be done using lambdas in configuration.

Sample configuration when your project uses FastGettext


.. code:: ruby

   Apipie.configure do |config|
    ...
    config.languages = ['en', 'cs']
    config.default_locale = 'en'
    config.locale = lambda { |loc| loc ? FastGettext.set_locale(loc) : FastGettext.locale }
    config.translate = lambda do |str, loc|
      old_loc = FastGettext.locale
      FastGettext.set_locale(loc)
      trans = _(str)
      FastGettext.set_locale(old_loc)
      trans
    end
   end

And the strings in the API documentation need to be marked with the ``N_()`` function

.. code:: ruby

  api :GET, "/users/:id", N_("Show user profile")
  param :session, String, :desc => N_("user is logged in"), :required => true



When your project use I18n, localization related configuration could appear as follows

.. code:: ruby

   Apipie.configure do |config|
    ...
    config.languages = ['en', 'cs']
    config.default_locale = 'en'
    config.locale = lambda { |loc| loc ? I18n.locale = loc : I18n.locale }
    config.translate = lambda do |str, loc|
      return '' if str.blank?
      I18n.t str, locale: loc, scope: 'doc'
    end
   end

And the strings in the API documentation needs to be in the form of translation keys

.. code:: ruby

  api :GET, "/users/:id", "show_user_profile"
  param :session, String, :desc => "user_is_logged_in", :required => true


The localized versions of the documentation are distinguished by language in the filename.
E.g. ``doc/apidoc/apidoc.cs.html`` is static documentation in the Czech language.
If the language is missing, e.g. ``doc/apidoc/apidoc.html``,
the documentation is localized with the ``default_locale``.

The dynamic documentation follows the same schema. The ``http://localhost:3000/apidoc/v1.cs.html`` is documentation for version '1' of the API in the Czech language. For JSON descriptions, the API applies the same format: ``http://localhost:3000/apidoc/v1.cs.json``


================
Modifying Views
================

To modify the views of your documentation, run ``rails g apipie:views``.
This will copy the Apipie views to ``app/views/apipie/apipies`` and
``app/views/layouts/apipie``.


==============
 Static files
==============

To generate a static version of documentation (perhaps to put it on
your project site or something), run the ``rake apipie:static`` task. It will
create a set of HTML files (multi-pages, single-page, plain) in your doc
directory. If you prefer a JSON version run ``rake apipie:static_json``.
By default the documentation for the default API version is
used. You can specify the version with ``rake apipie:static[2.0]``

When you want to avoid any unnecessary computation in production mode,
you can generate a cache with ``rake apipie:cache`` and configure the
app to use it in production with ``config.use_cache = Rails.env.production?``

Default cache dir is ``File.join(Rails.root, "public", "apipie-cache")``,
you can change it to where you want, example: ``config.cache_dir = File.join(Rails.root, "doc", "apidoc")``.

If, for some complex cases, you need to generate/re-generate just part of the cache
use ``rake apipie:cache cache_part=index`` resp. ``rake apipie:cache cache_part=resources``
To generate it for different locations for further processing use ``rake apipie:cache OUT=/tmp/apipie_cache``.

===================
 JSON checksums
===================

If the API client needs to be sure that the JSON didn't changed, add
the ``ApipieChecksumInHeaders`` middleware in your rails app.
It can add a checksum of the entire JSON document in the response headers.

.. code::

  "Apipie-Checksum"=>"fb81460e7f4e78d059f826624bdf9504"

`Apipie bindings <https://github.com/Apipie/apipie-bindings>`_ uses this feature to refresh its JSON cache.

To set it up add the following to your ``application.rb``

.. code::

   require 'apipie/middleware/checksum_in_headers'
   # Add JSON checksum in headers for smarter caching
   config.middleware.use "Apipie::Middleware::ChecksumInHeaders"

And in your apipie initializer allow checksum calculation

.. code::

   Apipie.configuration.update_checksum = true


By default the header is added to responses for ``config.doc_base_url`` and ``/api``.
It can be changed in configuration (see `Configuration Reference`_ for details).

The checksum calculation is lazy, and done with the first request. If you run with ``use_cache = true``,
do not forget to run the rake task ``apipie:cache``.


===================
 Tests Integration
===================

Apipie integrates with automated testing in two ways. *Documentation
bootstrapping* and *examples recording*.

Documentation Bootstrapping
---------------------------

Let's say you have an application without REST API documentation.
However you have a set of tests that are run against this API. A lot
of information is already included in these tests, it just needs to be
extracted somehow. Luckily, Apipie provides such a feature.

When running the tests, set the ``APIPIE_RECORD=params`` environment
variable or call ``Apipie.record('params')`` from specs starter. You can either use it with functional tests:

.. code::

   APIPIE_RECORD=params rake test:functionals

or you can run your server with this param, in case you run the tests
against running server:

.. code::

   APIPIE_RECORD=params rails server

When the process quits, the data from requests/responses are used to
determine the documentation. It's quite raw, but it makes the initial
phase much easier.

Examples Recording
------------------

You can also use the tests to generate up-to-date examples for your
code. Similar to the bootstrapping process, you can use it with functional
tests or a running server, setting ``APIPIE_RECORD=examples`` or calling ``Apipie.record('examples')`` in your specs starter.

.. code::

   APIPIE_RECORD=examples rake test:functionals
   APIPIE_RECORD=examples rails server

The data is written into ``doc/apipie_examples.yml``. By default,
only the first example is shown for each action. You can customize
this by setting the ``show_in_doc`` attribute at each example.

You can add a title to the examples (useful when showing more than
one example per method) by adding a 'title' attribute.

.. code::

   --- !omap
     - announcements#index:
       - !omap
         - title: This is a custom title for this example
         - verb: :GET
         - path: /api/blabla/1
         - versions:
           - '1.0'
         - query:
         - request_data:
         - response_data:
           ...
         - code: 200
         - show_in_doc: 1   # If 1, show. If 0, do not show.
         - recorded: true

In RSpec you can add metadata to examples. We can use that feature
to mark selected examples – the ones that perform the requests that we want to
show as examples in the documentation.

For example, we can add ``show_in_doc`` to examples, like this:

.. code:: ruby

   describe "This is the correct path" do
     it "some test", :show_in_doc do
       ....
     end
   end

   context "These are edge cases" do
     it "Can't authenticate" do
       ....
     end

      it "record not found" do
        ....
      end
   end

And then configure RSpec in this way:

.. code:: ruby

   RSpec.configure do |config|
     config.treat_symbols_as_metadata_keys_with_true_values = true
     config.filter_run :show_in_doc => true if ENV['APIPIE_RECORD']
   end

This way, when running in recording mode, only the tests that have been marked with the
``:show_in_doc`` metadata will be run, and hence only those will be used as examples.

Caveats
-------

Make sure to enable ``config.render_views`` in your ``config/rails_helper.rb`` or
``config/spec_helper.rb`` if you're using jbuilder, or you will get back empty results

====================
 Bindings Generator
====================

In earlier versions (<= 0.0.13), there was a simple client generator
as a part of Apipie gem. As more features and users came to Apipie,
there was a greater need for changes on a per project basis. It's
hard (or even impossible) to provide a generic solution for the client
code. We also don't want to tell you what's the right way to do it
(what gems to use, how the API should look like etc.).

Therefore you can't generate client code directly by a rake task in
further versions.

There is, however, an even better and more flexible way to reuse your API
documentation for this purpose: using the API the Apipie
provides in the generator code. Check out our sister project
`apipie-bindings <https://github.com/Apipie/apipie-bindings>`_, as they
use exactly this approach. You also don't need to run the service,
provided it uses Apipie as a backend.

And if you write one on your own, don't hesitate to share it with us!


====================
 Disqus Integration
====================

You can setup `Disqus <http://www.disqus.com>`_ discussion within
your documentation. Just set the credentials in the Apipie
configuration:

.. code:: ruby

   config.disqus_shortname = "MyProjectDoc"

=====================
 External References
=====================

* `Getting started tutorial <https://github.com/iNecas/apipie-demo>`_ -
  including examples of using the tests integration and versioning.

* `Real-world application usage <https://github.com/Katello/katello>`_

* `Read-world application usage with versioning <https://github.com/theforeman/foreman>`_

* `Using Apipie API to generate bindings <https://github.com/Apipie/apipie-bindings>`_
