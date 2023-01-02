class OverriddenConcernsController < ApplicationController

  resource_description { resource_id 'overridden_concern_resources' }

  apipie_concern_subst(:concern => 'user')
  include SampleController

  def_param_group :concern do
    param :concern, String
  end

  api :PUT, '/:resource_id/:id'
  param :custom_parameter, String, "New parameter added by the overriding method"
  param_group :concern, SampleController
  def update
    super
  end

  api :POST, '/:resource_id', "Create a :concern"
  param_group :concern
  def create
    super
  end

  api :GET, '/:resource_id/custom'
  param :concern, String
  def custom
    render :text => "OK #{params.inspect}"
  end

end
