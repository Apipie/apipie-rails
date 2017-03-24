require 'apipie/render'

module Apipie
  module Render
    module Markdown

      def self.one_page(file_base, doc, lang = nil)
        FileUtils.mkdir_p(File.dirname(file_base)) unless File.exists?(File.dirname(file_base))

        Render.page("#{file_base}-onepage#{Render.lang_ext(lang)}.md", "static", {
          :doc => doc[:docs],
          :language => lang,
          :languages => Apipie.configuration.languages
        }, 'apipie', [:md])
      end

      def self.resource_pages(version, file_base, doc, include_json = false, lang = nil)
        doc[:docs][:resources].each do |resource_name, _|
          resource_file_base = File.join(file_base, resource_name.to_s)
          FileUtils.mkdir_p(File.dirname(resource_file_base)) unless File.exists?(File.dirname(resource_file_base))

          doc = Apipie.to_json(version, resource_name, nil, lang)
          doc[:docs][:link_extension] = (lang ? ".#{lang}.md" : ".md")

          Render.page("#{resource_file_base}#{Render.lang_ext(lang)}.md", "resource", {
            :doc => doc[:docs],
            :resource => doc[:docs][:resources].first,
            :language => lang,
            :languages => Apipie.configuration.languages
          }, 'apipie', [:md])
        end
      end

      def self.method_pages(version, file_base, doc, include_json = false, lang = nil)
        doc[:docs][:resources].each do |resource_name, resource_params|
          resource_params[:methods].each do |method|
            method_file_base = File.join(file_base, resource_name.to_s, method[:name].to_s)
            FileUtils.mkdir_p(File.dirname(method_file_base)) unless File.exists?(File.dirname(method_file_base))

            doc = Apipie.to_json(version, resource_name, method[:name], lang)
            doc[:docs][:link_extension] = (lang ? ".#{lang}.md" : ".md")
            Render.page("#{method_file_base}#{Render.lang_ext(lang)}.md", "method", {
              :doc => doc[:docs],
              :resource => doc[:docs][:resources].first,
              :method => doc[:docs][:resources].first[:methods].first,
              :language => lang,
              :languages => Apipie.configuration.languages
            }, 'apipie')
          end
        end
      end

    end
  end
end
