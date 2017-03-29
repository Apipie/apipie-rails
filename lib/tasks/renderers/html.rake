# -*- coding: utf-8 -*-
require 'fileutils'
require 'apipie/render/html'

namespace :apipie do
  namespace :render do

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
    task :html, [:version] => :environment do |t, args|
      Apipie::Render.with_loaded_documentation do
        args.with_defaults(:version => Apipie.configuration.default_version)
        out = ENV["OUT"] || File.join(::Rails.root, Apipie.configuration.doc_path, 'apidoc')
        subdir = File.basename(out)
        Apipie::Render::HTML.copy_jscss(out)
        Apipie.configuration.version_in_url = false
        ([nil] + Apipie.configuration.languages).each do |lang|
          I18n.locale = lang || Apipie.configuration.default_locale
          Apipie.url_prefix = "./#{subdir}"
          doc = Apipie.to_json(args[:version], nil, nil, lang)
          doc[:docs][:link_extension] = "#{Apipie::Render.lang_ext(lang)}.html"
          Apipie::Render::HTML.one_page(out, doc, lang)
          Apipie::Render::HTML.plain_page(out, doc, lang)
          Apipie::Render::HTML.index_page(out, doc, false, false, lang)
          Apipie.url_prefix = "../#{subdir}"
          Apipie::Render::HTML.resource_pages(args[:version], out, doc, false, lang)
          Apipie.url_prefix = "../../#{subdir}"
          Apipie::Render::HTML.method_pages(args[:version], out, doc, false, lang)
        end
      end
    end

  end

end
