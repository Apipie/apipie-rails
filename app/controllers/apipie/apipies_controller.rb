module Apipie
  class ApipiesController < ActionController::Base
    layout 'apipie/apipie'

    def index

      params[:version] ||= Apipie.configuration.default_version

      get_format

      respond_to do |format|

        return if cache_used?

        Apipie.reload_documentation if Apipie.configuration.reload_controllers?
        @doc = Apipie.to_json(params[:version], params[:resource], params[:method])

        format.json do
          render :json => @doc
        end

        format.html do
          @versions = Apipie.available_versions
          @doc = @doc[:docs]
          @resource = @doc[:resources].first if params[:resource].present?
          @method = @resource[:methods].first if params[:method].present?

          if @resource && @method
            render 'method'
          elsif @resource
            render 'resource'
          else
            render 'index'
          end
        end
      end
    end

    private

    def get_format
      params[:format] = 'html' unless params[:version].sub!('.html', '').nil?
      params[:format] = :json unless params[:version].sub!('.json', '').nil?
      request.format = params[:format] if params[:format]
    end

    def cache_used?
      if Apipie.configuration.use_cache?
        path = Apipie.configuration.doc_base_url.dup
        if [:resource, :method, :format].any? { |p| params[p].to_s =~ /\W/ }
          head :bad_request and return
        end

        path << "/" << params[:version] if params[:version].present?
        path << "/" << params[:resource] if params[:resource].present?
        path << "/" << params[:method] if params[:method].present?
        if params[:format].present?
          path << ".#{params[:format]}"
        else
          path << ".html"
        end
        cache_file = File.join(Apipie.configuration.cache_dir, path)
        if File.exists?(cache_file)
          content_type = case params[:format]
                         when "json" then "application/json"
                         else "text/html"
                         end
          send_file cache_file, :type => content_type, :disposition => "inline"
        else
          Rails.logger.error("API doc cache not found for '#{path}'. Perhaps you have forgot to run `rake apipie:cache`")
          head :not_found
        end
        return true
      end
    end

  end
end
