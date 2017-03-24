# -*- coding: utf-8 -*-
require 'fileutils'
require 'apipie/render/markdown'

namespace :apipie do

  namespace :render do
    desc "Generate static markdown documentation"
    task :markdown, [:version] => :environment do |t, args|
      Apipie::Render.with_loaded_documentation do
        args.with_defaults(:version => Apipie.configuration.default_version)
        out = ENV["OUT"] || File.join(::Rails.root, Apipie.configuration.doc_path, 'apidoc')
        subdir = File.basename(out)
        Apipie.configuration.version_in_url = false
        ([nil] + Apipie.configuration.languages).each do |lang|
          I18n.locale = lang || Apipie.configuration.default_locale
          Apipie.url_prefix = "./#{subdir}"
          doc = Apipie.to_json(args[:version], nil, nil, lang)
          doc[:docs][:link_extension] = "#{Apipie::Render.lang_ext(lang)}.md"
          Apipie::Render::Markdown.one_page(out, doc, lang)
        end
      end
    end

  end

end
