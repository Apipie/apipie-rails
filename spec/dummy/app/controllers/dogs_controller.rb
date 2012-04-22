class DogsController < ApplicationController
  
  api :desc => "Show dogs profile",
      :path => "/dogs/:id",
      :method => "GET"
  error :code => 401, :desc => "Unauthorized"
  error :code => 404, :desc => "Not Found"
  desc "+Show dog+ This is *description* of dog show method."
  def show
    render :nothing => true
  end

  api :desc => "List all dogs",
      :path => "/dogs",
      :method => "GET"
  desc "List all dogs which are registered on our social site."
  def index
    render :text => "List of dogs"
  end
end