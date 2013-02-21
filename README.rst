========================
 API Documentation Tool
========================

.. image:: https://secure.travis-ci.org/Pajk/apipie-rails.png?branch=master

Apipie-rails is a DSL and Rails engine for documenting you RESTful
API. Instead of traditional use of ``#comments``, Apipie let's you
describe the code by code. This brings advantages like:

* no need to learn yet another syntax, you already know Ruby, right?
* possibility reuse the doc for other purposes (such as validation)
* easier to extend and maintain (no string parsing involved)
* possibility to use other sources for documentation purposes (such as
  routes etc.)

The documentation is available right in your app (by default under
``/apipie`` path. In development mode, you can see the changes as you
go. It's markup language agnostic and even provides an API for reusing
the documentation data in form of JSON.

Getting started
---------------

The easiest way to get Apipie up and running with your app is:

.. code::

   $ echo "gem 'apipie-rails'" >> Gemfile
   $ bundle install
   $ rails g apipie:install

Now you can start documenting your resources and actions (see
`DSL Reference`_ for more info:

.. code:: ruby

   api :GET, '/users/:id'
   param :id, :number
   def show
     # ...
   end


Run your application and see the result at
``http://localhost:3000/apipie``. For it's further processing, you can
use ``http://localhost:3000/apipie.json``.

For more comprehensive getting started guide, see
`this demo <https://github.com/iNecas/apipie-demo>`_, that includes
features such as generating documenation from tests, recording examples etc.

Screenshots
-----------

.. image:: https://img.skitch.com/20120428-nruk3e87xs2cu4ydsjujdh11fq.png
.. image:: https://img.skitch.com/20120428-bni2cmq5cyhjuw1jkd78e3qjxn.png

Authors
-------

`Pajk <https://github.com/Pajk>`_ and `iNecas <https://github.com/iNecas>`_

Contributors
------------

See `Contributors page  <https://github.com/Pajk/apipie-rails/graphs/contributors>`_. Special thanks to all of them!

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

You can describe a resource on controller level. The description is introduced by calling
``resource_description do ... end``.

Inheritance is supported, so you can specify common params for group of controllers in their parent
class.

The following keywords are available (all are optional):

resource_id
  How will the resource be referenced in Apipie (paths, ``see`` command etc.), by default `controller_name.downcase` is used.

name
  Human readable name of resource. By default ``class.name.humanize`` is used.

short (also short_description)
  Short description of the resource (it's shown on both list of resources and resource details)

desc (also description and full_description)
  Full description of the resource (shown only in resource details)

param
  Common params for all methods defined in controller/child controllers.

api_base_url
  What url is the resource available under.

api_versions (also api_version)
  What versions does the controller define the resource. (See `Versioning`_ for details.)

formats
  request / response formats.

error
  Describe every possible error that can happen what calling all
  methods defined in controller. HTTP response code and description can be provided.

app_info
  In case of versioning, this sets app info description on per_version basis.

Example:
~~~~~~~~

.. code:: ruby

   resource_description do
     short 'Site members'
     path '/users'
     formats ['json']
     param :id, Fixnum, :desc => "User ID", :required => false
     param :resource_param, Hash, :desc => 'Param description for all methods' do
       param :ausername, String, :desc => "Username for login", :required => true
       param :apassword, String, :desc => "Password for login", :required => true
     end
     api_version "development"
     error 404, "Missing"
     error 500, "Server crashed for some <%= reason %>"
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
  Say how is this method exposed and provide short description.
  The first parameter is HTTP method (one of :GET/:POST/:PUT/:DELETE).
  The second parameter is relative URL path which is mapped to this
  method. The last parameter is methods short description.
  You can use this +api+ method more than once for one method. It could
  be useful when there are more routes mapped to it.

api_versions (also api_version)
  What version(s) does the action belong to. (See `Versioning`_ for details.)

param
  Look at Parameter description section for details.

formats
  Method level request / response formats.

error
  Describe each possible error that can happen what calling this
  method. HTTP response code and description can be provided.

description
  Full method description which will be converted to HTML by
  chosen markup language processor.

example
  Provide example of server response, whole communication or response type.
  It will be formatted as code.

see
  Provide reference to another method, this has to be string with
  controller_name#method_name.

Example:
~~~~~~~~

.. code:: ruby

   api :GET, "/users/:id", "Show user profile"
   error :code => 401, :desc => "Unauthorized"
   error :code => 404, :desc => "Not Found"
   param :session, String, :desc => "user is logged in", :required => true
   param :regexp_param, /^[0-9]* years/, :desc => "regexp param"
   param :array_param, [100, "one", "two", 1, 2], :desc => "array validator"
   param :boolean_param, [true, false], :desc => "array validator with boolean"
   param :proc_param, lambda { |val| 
     val == "param value" ? true : "The only good value is 'param value'."
   }, :desc => "proc validator"
   description "method description"
   formats ['json', 'jsonp', 'xml']
   example " 'user': {...} "
   see "users#showme", "link description"
   see :link => "users#update", :desc => "another link description"
   def show
     #...
   end


Parameter Description
---------------------

Use ``param`` to describe every possible parameter. You can use Hash validator
in cooperation with block given to param method to describe nested parameters.

name
  The first argument is parameter name as a symbol.

validator
  Second parameter is parameter validator, choose one from section `Validators`_

desc
  Parameter description.

required
  Set this true/false to make it required/optional. Default is optional

allow_nil
  Set true is ``nil`` can be passed for this param.

Example:
~~~~~~~~

.. code:: ruby

   param :user, Hash, :desc => "User info" do
     param :username, String, :desc => "Username for login", :required => true
     param :password, String, :desc => "Password for login", :required => true
     param :membership, ["standard","premium"], :desc => "User membership"
   end
   def create
     #...
   end

DRY with param_group
--------------------

Often, params occur together in more actions. Typically, most of the
params for ``create`` and ``update`` actions are common for both of
them.

This params can be extracted with ``def_param_group`` and
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

In CRUD operations, this pattern occurs quite often: params that need
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
       param :description, :String
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

Action awareness is being inherited from ancestors (in terms of
nested params).


=========================
 Configuration Reference
=========================

Create configuration file in e.g. ``/config/initializers/apipie.rb``.
You can set  application name, footer text, API and documentation base URL
and turn off validations. You can also choose your favorite markup language
of full descriptions.

app_name
  Name of your application used in breadcrumbs navigation.

copyright
  Copyright information (shown in page footer).

doc_base_url
  Documentation frontend base url.

api_base_url
  Base url of your API, most probably /api.

default_version
  Default API version to be used (1.0 by default)

validate
  Parameters validation is turned off when set to false.

app_info
  Application long description.

reload_controllers
  Set to enable/disable reloading controllers (and the documentation with it), by default enabled in development.

api_controllers_matcher
  For reloading to work properly you need to specify where your API controllers are.

markup
  You can choose markup language for descriptions of your application,
  resources and methods. RDoc is the default but you can choose from
  Apipie::Markup::Markdown.new or Apipie::Markup::Textile.new.
  In order to use Markdown you need Redcarpet gem and for Textile you
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


Example:

.. code:: ruby

   Apipie.configure do |config|
     config.app_name = "Test app"
     config.copyright = "&copy; 2012 Pavel Pokorny"
     config.doc_base_url = "/apidoc"
     config.api_base_url = "/api"
     config.validate = false
     config.markup = Apipie::Markup::Markdown.new
     config.reload_controllers = true
     config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
     config.app_info = "
       This is where you can inform user about your application and API
       in general.
     ", '1.0'
   end


============
 Validators
============

Every parameter needs to have associated validator. For now there are some
basic validators. You can always provide your own to reach complex
results.

If validations are enabled (default state) the parameters of every
request are validated. If the value is wrong a +ArgumentError+ exception
is raised and can be rescued and processed. It contains some description
of parameter value expectations. Validations can be turned off
in configuration file.


TypeValidator
-------------
Check the parameter type. Only String, Hash and Array are supported
for the sake of simplicity. Read more to to find out how to add
your own validator.

.. code:: ruby

   param :session, String, :desc => "user is logged in", :required => true
   param :facts, Hash, :desc => "Additional optional facts about the user"


RegexpValidator
---------------
Check parameter value against given regular expression.

.. code:: ruby

   param :regexp_param, /^[0-9]* years/, :desc => "regexp param"


ArrayValidator
--------------

Check if parameter value is included given array.

.. code:: ruby

   param :array_param, [100, "one", "two", 1, 2], :desc => "array validator"


ProcValidator
-------------

If you need more complex validation and you know you won't reuse it you
can use Proc/lambda validator. Provide your own Proc taking value
of parameter as the only argument. Return true if value pass validation
or return some text about what is wrong. _Don't use the keyword *return*
if you provide instance of Proc (with lambda it is ok), just use the last
statement return property of ruby.

.. code:: ruby

   param :proc_param, lambda { |val|
     val == "param value" ? true : "The only good value is 'param value'."
   }, :desc => "proc validator"


HashValidator
-------------

You can describe hash parameters in depth if you provide a block with
description of nested values.

.. code:: ruby

   param :user, Hash, :desc => "User info" do
     param :username, String, :desc => "Username for login", :required => true
     param :password, String, :desc => "Password for login", :required => true
     param :membership, ["standard","premium"], :desc => "User membership"
   end


NilValidator
------------

In fact there is any NilValidator but setting it to nil can be used to
override parameters described on resource level.

.. code:: ruby

   param :user, nil
   def destroy
     #...
   end


Adding custom validator
-----------------------

Only basic validators are included but it is really easy to add your own.
Create new initializer with subclass of Apipie::Validator::BaseValidator.
Two methods are required to implement - instance method
<tt>validate(value)</tt> and class method
<tt>build(param_description, argument, options, block)</tt>.

When searching for validator +build+ method of every subclass of
Apipie::Validator::BaseValidator is called. The first one whitch return
constructed validator object is used.

Example: Adding IntegerValidator

We want to check if parameter value is an integer like this:

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
  given informations about validated parameter.

argument
  Specified validator, in our example it is +Integer+

options
  Hash with specified options, for us just ``{:desc => "Company ID"}``

block
  Block converted into Proc, use it as you desire. In this example nil.


============
 Versioning
============

Every resource/method can belong to one or more versions. The version is
specified with the `api_version` DSL keyword. When not specified,
the resource belong to `config.default_version` ("1.0" by default)

.. code:: ruby

   resource_description do
     api_versions "1", "2"
   end

   api :GET, "/api/users/"
   api_version "1"
   def index
     # ...
   end

In the example above we say the whole controller/resource is defined
for versions "1" and "2", but we override this with explicitly saying
`index` belongs only to version "1". Also inheritance works (therefore
we can specify the api_version for the parent controller and all
children will know about that).

From the Apipie API perspective, the resources belong to version.
With versioning, there are paths like this provided by apipie:

.. code::

   /apipie/1/users/index
   /apipie/2/users/index

When not specifying the version explicitly in the path (or in dsl),
default version (`Apipie.configuration.default_version`) is used
instead ("1.0" by default). Therefore, the application that doesn't
need versioning should work as before.

The static page generator takes version parameter (or uses default).

You can specify the versions for the examples, with `versions`
keyword. It specifies the versions the example is used for. When not
specified, it's shown in all versions with given method.

When referencing or quering the resource/method descripion, this
format should be used: "verson#resource#method". When not specified,
the default version is used instead.


========
 Markup
========

The default markup language is `RDoc
<http://rdoc.rubyforge.org/RDoc/Markup.html>`_. It can be changed in
config file (``config.markup=``) to one of these:

Markdown
  Use Apipie::Markup::Markdown.new. You need Maruku gem.

Textile
  Use Apipie::Markup::Textile.new. You need RedCloth gem.

Or provide you own object with ``to_html(text)`` method.
For inspiration this is how Textile markup usage looks like:

.. code:: ruby

   class Textile
     def initialize
       require 'RedCloth'
     end
     def to_html(text)
       RedCloth.new(text).to_html
     end
   end


==============
 Static files
==============

To generate static version of documentation (perhaps to put it on
project site or something) run ``rake apipie:static`` task. It will
create set of html files (multi-pages, single-page, plain) in your doc
directory. By default the documentation for default API version is
used, you can specify the version with ``rake apipie:static[2.0]``

When you want to avoid any unnecessary computation in production mode,
you can generate a cache with ``rake apipie:cache`` and configure the
app to use it in production with ``config.use_cache = Rails.env.production?``

===================
 Tests Integration
===================

Apipie integrates with automated testing in two ways. *Documentation
bootstrapping* and *examples recording*.

Documentation Bootstrapping
---------------------------

Let's say you have an application without REST API documentation.
However you have a set of tests that are run against this API. A lot
of information is already included in this tests, it just needs to be
extracted somehow. Luckily, Apipie provides such a feature.

When running the tests, set the ``APIPIE_RECORD=params`` environment
variable. You can either use it with functional tests

.. code::

   APIPIE_RECORD=params rake test:functionals

or you can run your server with this param, in case you run the tests
against running server

.. code::

   APIPIE_RECORD=params rails server

When the process quits, the data from requests/responses are used to
determine the documentation. It's quite raw, but it makes the initial
phase much easier.

Examples Recording
------------------

You can also use the tests to generate up-to-date examples for your
code. Similarly to the bootstrapping, you can use it with functional
tests or a running server, setting ``APIPIE_RECORD=examples``

.. code::

   APIPIE_RECORD=examples rake test:functionals
   APIPIE_RECORD=examples rails server

The data are written into ``doc/apipie_examples.yml``. By default,
only the first example is shown for each action. You can customize
this by setting ``show_in_doc`` attribute at each example.


====================
 Bindings Generator
====================

In earlier versions (<= 0.0.13), there was a simple client generator
as a part of Apipie gem. As more features and users came to Apipie,
more and more there was a need for changes on per project basis. It's
hard (or even impossible) to provide a generic solution for the client
code. We also don't want to tell you what's the rigth way to do it
(what gems to use, how the API should look like etc.).

Therefore you can't generate a client code directly by a rake task in
further versions.

There is, however, even better and more flexible way to reuse your API
documentation for this purpose: using the API the Apipie
provides in the generator code. You can inspire by
`Foreman API bindings <https://github.com/mbacovsky/foreman_api>`_ that
use exactly this approach. You also don't need to run the service,
provided it uses Apipie as a backend.

And if you write one on your own, don't hesitate to share it with us!

====================
 Disqus Integration
====================

You can get a `Disqus <http://www.disqus.com>`_ discussion for the
right into your documentation. Just set the credentials in Apipie
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

* `Using Apipie API to generate bindings <https://github.com/mbacovsky/foreman_api>`_
