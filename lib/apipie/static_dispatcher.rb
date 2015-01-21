module Apipie

  class FileHandler
    def initialize(root)
      @root          = root.chomp('/')
      @compiled_root = /^#{Regexp.escape(root)}/
      @file_server   = ::Rack::File.new(@root)
    end

    def match?(path)
      path = path.dup

      full_path = path.empty? ? @root : File.join(@root, ::Rack::Utils.unescape(path))
      paths = "#{full_path}#{ext}"

      matches = Dir[paths]
      match = matches.detect { |m| File.file?(m) }
      if match
        match.sub!(@compiled_root, '')
        match
      end
    end

    def call(env)
      @file_server.call(env)
    end

    def ext
      @ext ||= begin
        ext = cache_extension
        "{,#{ext},/index#{ext}}"
      end
    end

    def cache_extension
      if ::ActionController::Base.respond_to?(:default_static_extension)
        ::ActionController::Base.default_static_extension
      else
        ::ActionController::Base.page_cache_extension
      end

    end
  end

  class StaticDispatcher
    # Dispatches the static files. Similar to ActionDispatch::Static, but
    # it supports different baseurl configurations
    def initialize(app, path)
      @app = app
      @file_handler = Apipie::FileHandler.new(path)
    end

    def call(env)
      @baseurl ||= Apipie.configuration.doc_base_url
      case env['REQUEST_METHOD']
      when 'GET', 'HEAD'
        path = env['PATH_INFO'].sub("#{@baseurl}/","/apipie/").chomp('/')

        if match = @file_handler.match?(path)
          env["PATH_INFO"] = match
          return @file_handler.call(env)
        end
      end

      @app.call(env)
    end
  end
end
