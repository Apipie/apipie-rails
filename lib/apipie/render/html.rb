require 'apipie/render'

module Apipie
  module Render
    module HTML

      def self.one_page(file_base, doc, lang = nil)
        FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))

        Render.page("#{file_base}-onepage#{Render.lang_ext(lang)}.html", "static", {:doc => doc[:docs],
          :language => lang, :languages => Apipie.configuration.languages})
      end

      def self.plain_page(file_base, doc, lang = nil)
        FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))

        Render.page("#{file_base}-plain#{Render.lang_ext(lang)}.html", "plain", {:doc => doc[:docs],
          :language => lang, :languages => Apipie.configuration.languages}, nil)
      end

      def self.index_page(file_base, doc, include_json = false, show_versions = false, lang = nil)
        FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))
        versions = show_versions && Apipie.available_versions
        Render.page("#{file_base}#{Render.lang_ext(lang)}.html", "index", {:doc => doc[:docs],
          :versions => versions, :language => lang, :languages => Apipie.configuration.languages})

        File.open("#{file_base}#{Render.lang_ext(lang)}.json", "w") { |f| f << doc.to_json } if include_json
      end

      def self.resource_pages(version, file_base, doc, include_json = false, lang = nil)
        doc[:docs][:resources].each do |resource_name, _|
          resource_file_base = File.join(file_base, resource_name.to_s)
          FileUtils.mkdir_p(File.dirname(resource_file_base)) unless File.exists?(File.dirname(resource_file_base))

          doc = Apipie.to_json(version, resource_name, nil, lang)
          doc[:docs][:link_extension] = (lang ? ".#{lang}.html" : ".html")
          Render.page("#{resource_file_base}#{Render.lang_ext(lang)}.html", "resource", {:doc => doc[:docs],
            :resource => doc[:docs][:resources].first, :language => lang, :languages => Apipie.configuration.languages})
          File.open("#{resource_file_base}#{Render.lang_ext(lang)}.json", "w") { |f| f << doc.to_json } if include_json
        end
      end

      def self.method_pages(version, file_base, doc, include_json = false, lang = nil)
        doc[:docs][:resources].each do |resource_name, resource_params|
          resource_params[:methods].each do |method|
            method_file_base = File.join(file_base, resource_name.to_s, method[:name].to_s)
            FileUtils.mkdir_p(File.dirname(method_file_base)) unless File.exists?(File.dirname(method_file_base))

            doc = Apipie.to_json(version, resource_name, method[:name], lang)
            doc[:docs][:link_extension] = (lang ? ".#{lang}.html" : ".html")
            Render.page("#{method_file_base}#{Render.lang_ext(lang)}.html", "method", {
              :doc => doc[:docs],
              :resource => doc[:docs][:resources].first,
              :method => doc[:docs][:resources].first[:methods].first,
              :language => lang,
              :languages => Apipie.configuration.languages
            })

            File.open("#{method_file_base}#{Render.lang_ext(lang)}.json", "w") { |f| f << doc.to_json } if include_json
          end
        end
      end

      def self.copy_jscss(dest)
        src = File.expand_path(Apipie.root.join('app', 'public', 'apipie'))
        FileUtils.mkdir_p dest
        FileUtils.cp_r "#{src}/.", dest
      end

    end
  end
end
