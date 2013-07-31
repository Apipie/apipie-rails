module Apipie
  class ApipiesController < ActionController::Base
    layout Apipie.configuration.layout

    around_filter :set_script_name

    def index

      params[:version] ||= Apipie.configuration.default_version

      get_format

      respond_to do |format|

        if Apipie.configuration.use_cache?
          render_from_cache
          return
        end

        Apipie.reload_documentation if Apipie.configuration.reload_controllers?
        @doc = Apipie.to_json(params[:version], params[:resource], params[:method])

        format.json do
          render :json => @doc
        end

        format.html do
          @versions = Apipie.available_versions
          @doc = @doc[:docs]
          if @doc[:resources].blank?
            render "getting_started" and return
          end
          @resource = @doc[:resources].first if params[:resource].present?
          @method = @resource[:methods].first if params[:method].present?

          if @resource && @method
            render 'method'
          elsif @resource
            render 'resource'
          elsif params[:resource].present? || params[:method].present?
            render 'apipie_404', :status => 404
          else
            render 'index'
          end
        end
      end
    end

    private

    def get_format
      params[:format] = :html unless params[:version].sub!('.html', '').nil?
      params[:format] = :json unless params[:version].sub!('.json', '').nil?
      request.format = params[:format] if params[:format]
    end

    def render_from_cache
      path = Apipie.configuration.doc_base_url.dup
      if [:resource, :method, :format].any? { |p| params[p].to_s =~ /\W/ }
        head :bad_request and return
      end
      # version can contain dot, but only one in row
      if params[:version].to_s.gsub(".", "") =~ /\W/ ||
        params[:version].to_s =~ /\.\./
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

      # we sanitize the params before so in ideal case, this condition
      # will be never satisfied. It's here for cases somebody adds new
      # param into the path later and forgets about sanitation.
      if path =~ /\.\./
        head :bad_request and return
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
    end

    def set_script_name
      Apipie.request_script_name = request.env["SCRIPT_NAME"]
      yield
    ensure
      Apipie.request_script_name = nil
    end
  end
end
