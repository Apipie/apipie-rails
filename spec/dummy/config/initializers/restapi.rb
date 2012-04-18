Restapi.configure do |config|
  config.app_name = "Test app"
  config.app_info = <<-EOS
  == Getting Started

  1. Install Rails at the command prompt if you haven't yet:

      gem install rails

  2. At the command prompt, create a new Rails application:

      rails new myapp

     where "myapp" is the application name.

  3. Change directory to +myapp+ and start the web server:

      cd myapp; rails server

     Run with <tt>--help</tt> or <tt>-h</tt> for options.

  4. Go to http://localhost:3000 and you'll see:

      "Welcome aboard: You're riding Ruby on Rails!"
  EOS
  config.copyright = "&copy; 2012 Pavel Pokorny"
  config.baseurl = "/restapi"
  config.doc_base_url = "/restapi"
  config.api_base_url = "/api"
  config.markup_language = :rdoc
  # config.validate = false
end
