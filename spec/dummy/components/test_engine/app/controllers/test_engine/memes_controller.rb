module TestEngine
  class MemesController < TestEngine::ApplicationController
    api! 'Returns a list of all good memes on Twitter'
    param :api_token, String, required: true, desc: 'Your Twitter API token'
    def index
      render json: []
    end

    api! 'Shows info about a particular meme on Twitter'
    param :id, :number, required: true, desc: 'ID of the meme'
    def show
      render json: {id: params[:id]}
    end

    api! 'Create a new meme on Twitter'
    param :api_token, String, required: true, desc: 'Your Twitter API token'
    param :name, String, required: true, desc: 'Name of your meme'
    param :src_url, String, required: true, desc: 'URL for your meme'
    def create
      render json: {name: params[:name], src_url: params[:src_url]}, status: :created
    end

    api! 'Update a meme on Twitter'
    param :api_token, String, required: true, desc: 'Your Twitter API token'
    param :name, String, required: false, desc: 'Name of your meme'
    param :src_url, String, required: false, desc: 'URL for your meme'
    def update
      render json: {name: params[:name], src_url: params[:src_url]}
    end

    api! 'Delete a meme on Twitter'
    param :id, :number, required: true, desc: 'ID of the meme'
    def destroy
      head :ok
    end
  end
end
