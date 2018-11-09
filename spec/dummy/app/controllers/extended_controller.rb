class ExtendedController < ApplicationController

  api :POST, '/extended'
  param :user, Hash do
    param :name, String
    param :password, String
  end
  def create
  end

  apipie_update_params([:create]) do
    param :admin, :boolean
  end
end
