# -*- coding: utf-8 -*-
require 'fileutils'
require 'apipie/render/json'

namespace :apipie do

  namespace :render do

    desc "Generate static documentation json"
    task :json, [:version] => :environment do |t, args|
      Apipie::Render.with_loaded_documentation do
        args.with_defaults(:version => Apipie.configuration.default_version)
        out = ENV["OUT"] || File.join(::Rails.root, Apipie.configuration.doc_path, 'apidoc')
        ([nil] + Apipie.configuration.languages).each do |lang|
          doc = Apipie.to_json(args[:version], nil, nil, lang)
          Apipie::Render::JSON.one_page(out, doc, lang)
        end
      end
    end

  end

end
