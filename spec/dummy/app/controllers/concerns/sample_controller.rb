module Concerns
  module SampleController
    extend Apipie::DSL::Concern

    api :GET, '/:controller_path'
    def index
      render :text => "OK #{params.inspect}"
    end

    api :GET, '/:resource_id/:id'
    param :id, String
    def show
      render :text => "OK #{params.inspect}"
    end

    def_param_group :concern do
      param :concern, Hash, :required => true, :action_aware => true do
        param :name, String, "Name of a :concern"
        param :concern_type, String
      end
    end

    api :POST, '/:resource_id', "Create a :concern"
    param_group :concern
    def create
      render :text => "OK #{params.inspect}"
    end

    api :PUT, '/:resource_id/:id'
    param :id, String
    param_group :concern
    def update
      render :text => "OK #{params.inspect}"
    end

    api :GET, '/:resource_id/:custom_subst'
    def custom
      render :text => "OK #{params.inspect}"
    end
  end
end
