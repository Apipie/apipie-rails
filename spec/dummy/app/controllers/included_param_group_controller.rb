class IncludedParamGroupController < ApplicationController
  include RandomParamGroup

  api :GET, '/included-param-group'
  returns code:200 do
    property :top_level, Array, of: Hash do
      param_group :random_param_group
    end
    property :nested, Hash do
      property :random_array, Array, of: Hash do
        param_group :random_param_group
      end
    end
  end
  def show
  end

end

