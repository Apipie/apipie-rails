class FilesController < ApplicationController
  def download
    render :text => "dummy file body for #{params[:file_path]}"
  end
end
