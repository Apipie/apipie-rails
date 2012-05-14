namespace :restapi do

  desc "Generate static documentation"
  task :static => :environment do

    av = ActionView::Base.new(ActiveSupport::Dependencies.autoload_paths)

    av.class_eval do
      include ApplicationHelper
    end

    Dir[File.join(Rails.root, "app", "controllers", "**","*.rb")].each {|f| load f}

    doc = Restapi.to_json()[:docs]

    # dir in public directory
    dir_path = File.join(::Rails.root.to_s, 'public', Restapi.configuration.doc_base_url)
    FileUtils.rm_r(dir_path) if File.directory?(dir_path)
    Dir.mkdir(dir_path)

    copy_jscss(File.join(dir_path, Restapi.configuration.doc_base_url))

    Restapi.configuration.doc_base_url = Restapi.configuration.doc_base_url[1..-1]
    File.open(File.join(dir_path,'index.html'), "w") do |f|
      f.write av.render(
        :template => "restapi/restapis/static",
        :locals => {:doc => doc},
        :layout => 'layouts/restapi/restapi')
      puts File.join(dir_path,'index.html')
    end

  end

  def copy_jscss(dest)
    src = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'public', 'restapi'))
    FileUtils.cp_r "#{src}/.", dest
  end


  desc "Generate CLI client for API documented with restapi gem."
  task :client, [:api_base_url, :url_append]  => [:environment] do |t, args|

    args.with_defaults :api_base_url => 'http://localhost:3000', :url_append => ''

    ActiveSupport::Dependencies.autoload_paths.each do |path|
      Dir[path + "/*.rb"].each { |file| require file }
    end

    Dir.mkdir('clients') unless File.exists?('clients')

    doc = Restapi.to_json()[:docs]

    create_base doc, args

    create_cli doc
  end

  def ac(content, code, spaces = 0)
    content << " "*spaces << code << "\n"
  end

  def create_base doc, args
    content = ""
    ac content, "require 'rubygems'"
    ac content, "require 'weary'"
    ac content, "require 'thread' unless defined? Mutex\n"
    ac content, "API_BASE_URL = ENV['API_URL'] || '#{args[:api_base_url]}'"
    ac content, "URL_APPEND = ENV['URL_APPEND'] || '#{args[:url_append]}'\n"

    doc[:resources].each do |key, resource|

      ac content, "class #{key.camelize}Client < Weary::Client"
      ac content, "domain API_BASE_URL", 2
      resource[:methods].each do |method|
        method[:apis].each do |api|
          ac content, "# #{api[:short_description]}", 2
          ac content, "#{api[:http_method].downcase} :#{method[:name]}, \"#{api[:api_url]}\#{URL_APPEND}\" do |resource|", 2
          required = []
          optional = []

          method[:params].each do |param|
            if param[:required]
              required << param[:name].to_sym
            else
              optional << param[:name].to_sym
            end
          end
          ac content, "resource.optional :#{optional.join(', :')}", 4 unless optional.blank?
          ac content, "resource.required :#{required.join(', :')}", 4 unless required.blank?

          ac content, "end", 2
        end
      end
      ac content, "end\n"
    end

    File.open('clients/base.rb', 'w') { |f| f.write content }
  end

  def create_cli doc

    content = ""
    ac content, "require 'rubygems'"
    ac content, "require 'thor'"
    ac content, "require 'base'"

    doc[:resources].each do |key, resource|
      ac content, "class #{key.camelize} < Thor"
        # ac content, "$klasses['#{key}'] = #{key.camelize}", 2
        # ac content, "@client = RestClient::Resource.new \"\#{$API_URL}#{resource[:api_url]}\"\n", 2

        ac content, "no_tasks do", 2
        ac content, "  def client", 2
        ac content, "    @client ||= #{key.camelize}Client.new", 2
        ac content, "  end", 2
        ac content, "end", 2

        resource[:methods].each do |method|

          method[:apis].each do |api|

            params = []
            method[:params].each do |param|
              ac content, "method_option :#{param[:name]},", 2
              ac content, ":required => #{param[:required] ? 'true' : 'false' },", 4
              ac content, ":desc => '#{plaintext(param[:description])}',", 4
              ac content, ":type => :#{param[:expected_type]}", 4
              # :type — :string, :hash, :array, :numeric, or :boolean
              params << param[:name]
            end

            ac content, "desc '#{method[:name]}', '#{api[:short_description]}'", 2
            ac content, "def #{method[:name]}", 2
            ac content, "  resp = client.#{method[:name]}(options).perform do |response|", 2
            ac content, "    if response.success?", 2
            ac content, "      puts response.body", 2
            ac content, "    else", 2
            ac content, "      puts \"status: \#{response.status}\"", 2
            ac content, "      puts response.body", 2
            ac content, "    end", 2
            ac content, "  end", 2
            ac content, "  resp.status", 2
            ac content, "end\n", 2

          end

        end
      ac content, "end\n"
    end

    File.open('clients/cli.thor', 'w') { |f| f.write content }
  end

  def plaintext(text)
    text.gsub(/<.*?>/, '').gsub("\n",' ').strip
  end
end
