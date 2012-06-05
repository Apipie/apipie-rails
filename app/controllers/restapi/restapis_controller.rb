module Restapi
  class RestapisController < ActionController::Base
    layout 'restapi/restapi'
    
    def index
      respond_to do |format|

        if Restapi.configuration.use_cache?
          path = Restapi.configuration.doc_base_url.dup
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
          cache_file = File.join(Restapi.configuration.cache_dir, path)
          if File.exists?(cache_file)
            content_type = case params[:format]
                           when "json" then "application/json"
                           else "text/html"
                           end
            send_file cache_file, :type => content_type, :disposition => "inline"
          else
            Rails.logger.error("API doc cache not found for '#{path}'. Perhaps you have forgot to run `rake restapi:cache`")
            head :not_found
          end
          return
        end

        Restapi.reload_documentation if Restapi.configuration.reload_controllers?
        @doc = Restapi.to_json(params[:resource], params[:method])

        format.json do
          render :json => @doc
        end

        format.html do

          @doc = @doc[:docs]
          if params[:resource].present? && params[:method].present?
            @resource = @doc[:resources].first
            @method = @resource[:methods].first
            render 'method'
          elsif params[:resource].present?
            @resource = @doc[:resources].first
            render 'resource'
          else
            render 'index'
          end
        end
      end
    end

  end
end
