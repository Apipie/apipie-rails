module Apipie
  module Render
    # Attempt to use the Rails application views, otherwise default to built in views
    def self.renderer(formats = nil)
      return @apipie_renderer if @apipie_renderer

      @apipie_renderer = ActionView::Base.new([base_path, layouts_path], {}, nil, formats)
      @apipie_renderer.singleton_class.send(:include, ApipieHelper)
      return @apipie_renderer
    end

    def self.page(file_name, template, variables, layout = 'apipie', formats = nil)
      av = renderer(formats)
      File.open(file_name, "w") do |f|
        variables.each do |var, val|
          av.instance_variable_set("@#{var}", val)
        end
        f.write av.render(
          :template => "#{template}",
          :layout => (layout && "apipie/#{layout}"),
          :formats => formats)
      end
    end

    def self.with_loaded_documentation
      Apipie.configuration.use_cache = false # we don't want to skip DSL evaluation
      Apipie.reload_documentation
      yield
    end

    def self.copy_jscss(dest)
      src = File.expand_path(Apipie.root.join('app', 'public', 'apipie'))
      FileUtils.mkdir_p dest
      FileUtils.cp_r "#{src}/.", dest
    end

    def self.lang_ext(lang = nil)
      lang ? ".#{lang}" : ""
    end

    private

    def self.base_path
      if File.directory?("#{Rails.root}/app/views/apipie/apipies")
        "#{Rails.root}/app/views/apipie/apipies"
      else
        File.expand_path(Apipie.root.join('app', 'views', 'apipie', 'apipies'))
      end
    end

    def self.layouts_path
      if File.directory?("#{Rails.root}/app/views/layouts/apipie")
        "#{Rails.root}/app/views/layouts"
      else
        File.expand_path(Apipie.root.join('app', 'views', 'layouts'))
      end
    end
  end
end
