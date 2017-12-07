class ExtendedController < ApplicationController
  api :POST, '/extended'
  param :user, Hash do
    param :name, String
    param :password, String
  end
  def create; end
end
