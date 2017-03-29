# -*- coding: utf-8 -*-
require 'fileutils'
require 'apipie/render/html'

namespace :apipie do

  # By default the full cache is built.
  # It is possible to generate index resp. resources only with
  # rake apipie:cache cache_part=index (resources resp.)
  # Default output dir ('public/apipie_cache') can be changed with OUT=/some/dir
  desc "Generate cache to avoid production dependencies on markup languages"
  task :cache => :environment do
    puts "#{Time.now} | Started"
    cache_part = ENV['cache_part']
    generate_index = (cache_part == 'resources' ? false : true)
    generate_resources = (cache_part == 'index' ? false : true)
    Apipie::Render.with_loaded_documentation do
      puts "#{Time.now} | Documents loaded..."
      ([nil] + Apipie.configuration.languages).each do |lang|
        I18n.locale = lang || Apipie.configuration.default_locale
        puts "#{Time.now} | Processing docs for #{lang}"
        cache_dir = ENV["OUT"] || Apipie.configuration.cache_dir
        subdir = Apipie.configuration.doc_base_url.sub(/\A\//,"")
        subdir_levels = subdir.split('/').length
        subdir_traversal_prefix = '../' * subdir_levels
        file_base = File.join(cache_dir, Apipie.configuration.doc_base_url)

        if generate_index
          Apipie.url_prefix = "./#{subdir}"
          doc = Apipie.to_json(Apipie.configuration.default_version, nil, nil, lang)
          doc[:docs][:link_extension] = (lang ? ".#{lang}.html" : ".html")
          Apipie::Render::HTML.index_page(file_base, doc, true, false, lang)
        end
        Apipie.available_versions.each do |version|
          file_base_version = File.join(file_base, version)
          Apipie.url_prefix = "#{subdir_traversal_prefix}#{subdir}"
          doc = Apipie.to_json(version, nil, nil, lang)
          doc[:docs][:link_extension] = (lang ? ".#{lang}.html" : ".html")

          Apipie::Render::HTML.index_page(file_base_version, doc, true, true, lang) if generate_index
          if generate_resources
            Apipie.url_prefix = "../#{subdir_traversal_prefix}#{subdir}"
            Apipie::Render::HTML.resource_pages(version, file_base_version, doc, true, lang)
            Apipie.url_prefix = "../../#{subdir_traversal_prefix}#{subdir}"
            Apipie::Render::HTML.method_pages(version, file_base_version, doc, true, lang)
          end
        end
      end
    end
    puts "#{Time.now} | Finished"
  end

end
