# -*- coding: utf-8 -*-
require 'fileutils'
require 'restapi/client/generator'

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
      subdir = File.basename(out)

      copy_jscss(out)

      Restapi.url_prefix = "./#{subdir}"
      doc = Restapi.to_json
      generate_one_page(out, doc)
      generate_plain_page(out, doc)
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
    ActionView::Base.new(File.expand_path("../../../app/views/restapi/restapis", __FILE__))
  end

  def render_page(file_name, template, variables, layout = 'restapi')
    av = renderer
    File.open(file_name, "w") do |f|
      variables.each do |var, val|
        av.instance_variable_set("@#{var}", val)
      end
      f.write av.render(
        :template => "#{template}",
        :layout => (layout && "../../layouts/restapi/#{layout}"))
    end
  end

  def generate_one_page(file_base, doc)
    FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))

    render_page("#{file_base}-onepage.html", "static", {:doc => doc[:docs]})
  end

  def generate_plain_page(file_base, doc)
    FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))

    render_page("#{file_base}-plain.html", "plain", {:doc => doc[:docs]}, nil)
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
  task :client => [:environment] do |t, args|
    Restapi.configuration.use_cache = false # we don't want to skip DSL evaluation
    Restapi.api_controllers_paths.each { |file| require file }

    Restapi::Client::Generator.start(Restapi.configuration.app_name)
  end

end
