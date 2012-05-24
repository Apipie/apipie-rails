require 'fileutils'
namespace :restapi do

  desc "Generate static documentation"
  # You can specify OUT=output_base_file to have the following structure:
  #
  #    output_base_file.html
  #    output_base_file-onepage.html
  #    output_base_file
  #    | - resource1.html
  #    | - resource1
  #    | - | - method1.html
  #    | - | - method2.html
  #    | - resource2.html
  #
  # By default OUT="#{Rails.root}/doc/apidoc"
  task :static => :environment do
    with_loaded_documentation do
      out = ENV["OUT"] || File.join(::Rails.root, 'doc', 'apidoc')
      raise "File #{out} already exists" if File.exists?(out)
      subdir = File.basename(out)

      copy_jscss(out)

      Restapi.url_prefix = "./#{subdir}"
      doc = Restapi.to_json
      generate_one_page(out, doc)
      generate_index_page(out, doc)
      Restapi.url_prefix = "../#{subdir}"
      generate_resource_pages(out, doc)
      Restapi.url_prefix = "../../#{subdir}"
      generate_method_pages(out, doc)
    end
  end

  desc "Generate cache to avoid production dependencies on markup languages"
  task :cache => :environment do
    with_loaded_documentation do
      cache_dir = Restapi.configuration.cache_dir
      file_base = File.join(cache_dir, Restapi.configuration.doc_base_url)
      doc = Restapi.to_json
      generate_index_page(file_base, doc, true)
      generate_resource_pages(file_base, doc, true)
      generate_method_pages(file_base, doc, true)
    end
  end

  def renderer
    av = ActionView::Base.new(File.expand_path("../../../app/views", __FILE__))
    av.class_eval do
      include Restapi::RestapisHelper
    end
    av
  end

  def render_page(file_name, template, variables)
    av = renderer
    File.open(file_name, "w") do |f|
      variables.each do |var, val|
        av.instance_variable_set("@#{var}", val)
      end
      f.write av.render(
        :template => "restapi/restapis/#{template}",
        :layout => 'layouts/restapi/restapi')
    end
  end

  def generate_one_page(file_base, doc)
    FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))

    render_page("#{file_base}-onepage.html", "static", {:doc => doc[:docs]})
  end

  def generate_index_page(file_base, doc, include_json = false)
    FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))

    render_page("#{file_base}.html", "index", {:doc => doc[:docs]})

    File.open("#{file_base}.json", "w") { |f| f << doc.to_json } if include_json
  end

  def generate_resource_pages(file_base, doc, include_json = false)
    doc[:docs][:resources].each do |resource_name, _|
      resource_file_base = File.join(file_base, resource_name.to_s)
      FileUtils.mkdir_p(File.dirname(resource_file_base)) unless File.exists?(File.dirname(resource_file_base))

      doc = Restapi.to_json(resource_name)
      render_page("#{resource_file_base}.html", "resource", {:doc => doc[:docs],
                                                          :resource => doc[:docs][:resources].first})
      File.open("#{resource_file_base}.json", "w") { |f| f << doc.to_json } if include_json
    end
  end

  def generate_method_pages(file_base, doc, include_json = false)
    doc[:docs][:resources].each do |resource_name, resource_params|
      resource_params[:methods].each do |method|
        method_file_base = File.join(file_base, resource_name.to_s, method[:name].to_s)
        FileUtils.mkdir_p(File.dirname(method_file_base)) unless File.exists?(File.dirname(method_file_base))

        doc = Restapi.to_json(resource_name, method[:name])
        render_page("#{method_file_base}.html", "method", {:doc => doc[:docs],
                                                           :resource => doc[:docs][:resources].first,
                                                           :method => doc[:docs][:resources].first[:methods].first})

        File.open("#{method_file_base}.json", "w") { |f| f << doc.to_json } if include_json
      end
    end
  end

  def with_loaded_documentation
    Restapi.configuration.use_cache = false # we don't want to skip DSL evaluation
    Dir[File.join(Rails.root, "app", "controllers", "**","*.rb")].each {|f| load f}
    yield
  end

  def copy_jscss(dest)
    src = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'public', 'restapi'))
    FileUtils.mkdir_p dest
    FileUtils.cp_r "#{src}/.", dest
  end


  desc "Generate CLI client for API documented with restapi gem."
  task :client, [:api_base_url, :url_append]  => [:environment] do |t, args|

    args.with_defaults :api_base_url => 'http://localhost:3000', :url_append => ''

    ActiveSupport::Dependencies.autoload_paths.each do |path|
      Dir[path + "/*.rb"].each { |file| require file }
    end

    FileUtils.mkdir_p('clients') unless File.exists?('clients')

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
    ac content, "require './base'"

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
