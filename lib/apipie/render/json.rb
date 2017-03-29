require 'apipie/render'

module Apipie
  module Render
    module JSON

      def self.one_page(file_base, doc, lang = nil)
        FileUtils.mkdir_p(file_base) unless File.exists?(file_base)

        filename = "schema_apipie#{Render.lang_ext(lang)}.json"
        File.open("#{file_base}/#{filename}", 'w') { |file| file.write(::JSON.pretty_generate(doc)) }
      end

    end
  end
end
