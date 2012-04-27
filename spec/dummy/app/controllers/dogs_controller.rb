class DogsController < ApplicationController
  
  api :GET, "/dogs/:id", "Show dogs profile"
  error :code => 401, :desc => "Unauthorized"
  error :code => 404, :desc => "Not Found"
  desc "+Show dog+ This is *description* of dog show method."
  def show
    render :nothing => true
  end

  api :GET, "/dogs", "List all dogs"
  desc "List all dogs which are registered on our social site."
  def index
    render :text => "List of dogs"
  end
end
