module Apipie
  class ApipiesController < ActionController::Base
    layout Apipie.configuration.layout

    def index
      respond_to do |format|

        if Apipie.configuration.use_cache?
          path = Apipie.configuration.doc_base_url.dup
          if [:resource, :method, :format].any? { |p| params[p].to_s =~ /\W/ }
            head :bad_request and return
          end

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
          return
        end

        Apipie.reload_documentation if Apipie.configuration.reload_controllers?
        @doc = Apipie.to_json(params[:resource], params[:method])

        format.json do
          render :json => @doc
        end

        format.html do

          @doc = @doc[:docs]
          if params[:resource].present? && params[:method].present?
            @resource = @doc[:resources].first
            @method = @resource[:methods].first unless @resource == 'null'
            if @resource == 'null' || @method == 'null'
              render 'apipie_404', :status => 404
            else
              render 'method'
            end
          elsif params[:resource].present?
            @resource = @doc[:resources].first
            if @resource == 'null'
              render 'apipie_404', :status => 404
            else
              render 'resource'
            end
          else
            render 'index'
          end
        end
      end
    end

  end
end
