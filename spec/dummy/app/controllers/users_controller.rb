class UsersController < ApplicationController
  
  api :desc => "Show user profile",
      :path => "/users/:id",
      :method => "GET"
  error :code => 444, :desc => "random error"
  param :id, Integer, :desc => "user id", :required => true
  param :version, Integer, :desc => "user resource version", :required => true
  desc "+Show user+ This is *description* of user show method."
  def show
    @user = {:id => params[:id]}
    render :nothing => true
  end
end