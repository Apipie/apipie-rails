class UsersController < ApplicationController

  resource_description do
    short 'Site members'
    path '/users'
    formats ['json']
    param :id, Fixnum, :desc => "User ID", :required => false
    param :legacy_param, Hash, :desc => 'Deprecated parameter not documented', :show => false, :required => false do
      param :resource_param, Hash, :desc => 'Param description for all methods' do
        param :ausername, String, :desc => "Username for login", :required => true
        param :apassword, String, :desc => "Password for login", :required => true
      end
    end
    api_version "development"
    error 404, "Missing", :meta => {:some => "metadata"}
    error 500, "Server crashed for some <%= reason %>"
    meta :new_style => true, :author => { :name => 'John', :surname => 'Doe' }
    description <<-EOS
      == Long description

      Example resource for rest api documentation

      These can now be accessed in <tt>shared/header</tt> with:

        Headline: <%= headline %>
        First name: <%= person.first_name %>

      If you need to find out whether a certain local variable has been assigned a value in a particular render call,
      you need to use the following pattern:

        <% if local_assigns.has_key? :headline %>
          Headline: <%= headline %>
        <% end %>

      Testing using <tt>defined? headline</tt> will not work. This is an implementation restriction.

      === Template caching

      By default, Rails will compile each template to a method in order to render it. When you alter a template,
      Rails will check the file's modification time and recompile it in development mode.
    EOS
    header :CommonHeader, 'Common header description', required: true
  end

  description <<-eos
    = Action View Base

    Action View templates can be written in several ways. If the template file has a <tt>.erb</tt> extension then it uses a mixture of ERb
    (included in Ruby) and HTML. If the template file has a <tt>.builder</tt> extension then Jim Weirich's Builder::XmlMarkup library is used.

    == ERB

    You trigger ERB by using embeddings such as <% %>, <% -%>, and <%= %>. The <%= %> tag set is used when you want output. Consider the
    following loop for names:

      <b>Names of all the people</b>
      <% @people.each do |person| %>
        Name: <%= person.name %><br/>
      <% end %>

    The loop is setup in regular embedding tags <% %> and the name is written using the output embedding tag <%= %>. Note that this
    is not just a usage suggestion. Regular output functions like print or puts won't work with ERB templates. So this would be wrong:

      <%# WRONG %>
      Hi, Mr. <% puts "Frodo" %>

    If you absolutely must write from within a function use +concat+.

    <%- and -%> suppress leading and trailing whitespace, including the trailing newline, and can be used interchangeably with <% and %>.

    === Using sub templates

    Using sub templates allows you to sidestep tedious replication and extract common display structures in shared templates. The
    classic example is the use of a header and footer (even though the Action Pack-way would be to use Layouts):

      <%= render "shared/header" %>
      Something really specific and terrific
      <%= render "shared/footer" %>

    As you see, we use the output embeddings for the render methods. The render call itself will just return a string holding the
    result of the rendering. The output embedding writes it to the current template.

    But you don't have to restrict yourself to static includes. Templates can share variables amongst themselves by using instance
    variables defined using the regular embedding tags. Like this:

      <% @page_title = "A Wonderful Hello" %>
      <%= render "shared/header" %>

    Now the header can pick up on the <tt>@page_title</tt> variable and use it for outputting a title tag:

      <title><%= @page_title %></title>

    === Passing local variables to sub templates

    You can pass local variables to sub templates by using a hash with the variable names as keys and the objects as values:

      <%= render "shared/header", { :headline => "Welcome", :person => person } %>

    These can now be accessed in <tt>shared/header</tt> with:

      Headline: <%= headline %>
      First name: <%= person.first_name %>

    If you need to find out whether a certain local variable has been assigned a value in a particular render call,
    you need to use the following pattern:

      <% if local_assigns.has_key? :headline %>
        Headline: <%= headline %>
      <% end %>

    Testing using <tt>defined? headline</tt> will not work. This is an implementation restriction.

    === Template caching

    By default, Rails will compile each template to a method in order to render it. When you alter a template,
    Rails will check the file's modification time and recompile it in development mode.

    == Builder

    Builder templates are a more programmatic alternative to ERB. They are especially useful for generating XML content. An XmlMarkup object
    named +xml+ is automatically made available to templates with a <tt>.builder</tt> extension.

    Here are some basic examples:

      xml.em("emphasized")                                 # => <em>emphasized</em>
      xml.em { xml.b("emph & bold") }                      # => <em><b>emph &amp; bold</b></em>
      xml.a("A Link", "href" => "http://onestepback.org")  # => <a href="http://onestepback.org">A Link</a>
      xml.target("name" => "compile", "option" => "fast")  # => <target option="fast" name="compile"\>
                                                           # NOTE: order of attributes is not specified.

    Any method with a block will be treated as an XML markup tag with nested markup in the block. For example, the following:

      xml.div do
        xml.h1(@person.name)
        xml.p(@person.bio)
      end

    would produce something like:

      <div>
        <h1>David Heinemeier Hansson</h1>
        <p>A product of Danish Design during the Winter of '79...</p>
      </div>

    A full-length RSS example actually used on Basecamp:

      xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
        xml.channel do
          xml.title(@feed_title)
          xml.link(@url)
          xml.description "Basecamp: Recent items"
          xml.language "en-us"
          xml.ttl "40"

          @recent_items.each do |item|
            xml.item do
              xml.title(item_title(item))
              xml.description(item_description(item)) if item_description(item)
              xml.pubDate(item_pubDate(item))
              xml.guid(@person.firm.account.url + @recent_items.url(item))
              xml.link(@person.firm.account.url + @recent_items.url(item))

              xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
            end
          end
        end
      end

    More builder documentation can be found at http://builder.rubyforge.org.
  eos
  api :GET, "/users/:id", "Show user profile"
  show false
  formats ['json', 'jsonp']
  error 401, "Unauthorized"
  error :code => 404, :description => "Not Found"
  param :id, Integer, :desc => "user id", :required => true
  param :session, String, :desc => "user is logged in", :required => true, :missing_message => lambda { "session_parameter_is_required" }
  param :regexp_param, /^[0-9]* years/, :desc => "regexp param"
  param :regexp2, /\b[A-Z0-9._%+-=]+@[A-Z0-9.-]+.[A-Z]{2,}\b/i, :desc => "email regexp"
  param :array_param, ["100", "one", "two", "1", "2"], :desc => "array validator"
  param :boolean_param, [true, false], :desc => "array validator with boolean"
  param :proc_param, lambda { |val|
    val == "param value" ? true : "The only good value is 'param value'."
  }, :desc => "proc validator"
  param :briefer_dsl, String, "You dont need :desc => from now"
  param :meta_param, String, :desc => "A parameter with some additional metadata", :meta => [:some, :more, :info]
  meta :success_message => "Some message"
  param :hash_param, Hash, :desc => "Hash param" do
    param :dummy_hash, Hash do
      param :dummy_2, String, :required => true
    end
  end
  def show
    unless params[:session] == "secret_hash"
      render :plain => "Not authorized", :status => 401
      return
    end

    unless params[:id].to_i == 5
      render :plain => "Not Found", :status => 404 and return
    end

    render :plain => "OK"
  end

  def_param_group :credentials do
    param :name, String, :desc => "Username for login", :required => true
    param :pass, String, :desc => "Password for login", :required => true
  end

  def_param_group :user do
    param :user, Hash, :desc => "User info", :required => true, :action_aware => true do
      param_group :credentials
      param :membership, ["standard","premium"], :desc => "User membership", :allow_nil => false
    end
  end

  api :POST, "/users", "Create user"
  param_group :user
  param :user, Hash do
    param :permalink, String
  end
  param :facts, Hash, :desc => "Additional optional facts about the user", :allow_nil => true
  param :age, :number, :desc => "Age is just a number", :allow_blank => true
  error :unprocessable_entity, 'Unprocessable Entity'
  def create
    render :plain => "OK #{params.inspect}"
  end

  api :PUT, "/users/:id", "Update an user"
  param_group :user
  param :comments, Array do
    param :comment, String
  end
  def update
    render :plain => "OK #{params.inspect}"
  end

  api :POST, "/users/admin", "Create admin user"
  param_group :user, :as => :create
  def admin_create
    render :plain => "OK #{params.inspect}"
  end

  api :GET, "/users", "List users"
  error :code => 401, :desc => "Unauthorized"
  error :code => 404, :desc => "Not Found"
  desc "List all users."
  param :oauth, nil,
        :desc => "Hide this global param (eg dont need auth here)"
  def index
    render :plain => "List of users"
  end

  api :GET, '/company_users', 'Get company users'
  api :GET, '/company/:id/users', 'Get users working in given company'
  param :id, Integer, :desc => "Company ID"
  def two_urls
    render :plain => 'List of users'
  end

  api :GET, '/users/see_another', 'Boring method'
  show false
  see 'development#users#create'
  see 'development#users#index', "very interesting method reference"
  desc 'This method is boring, look at users#create.  It is hidden from documentation.'
  def see_another
    render :plain => 'This is very similar to create action'
  end


  api :GET, '/users/desc_from_file', 'desc from file'
  document 'users/desc_from_file.md'
  def desc_from_file
    render :plain => 'document from file action'
  end

  api! 'Create user'
  param_group :user
  param :user, Hash do
    param :permalink, String
  end
  param :facts, Hash, :desc => "Additional optional facts about the user", :allow_nil => true
  def create_route
  end

  api :GET, '/users/action_with_headers'
  header :RequredHeaderName, 'Required header description', required: true
  header :OptionalHeaderName, 'Optional header description', required: false
  def action_with_headers
  end
end
