TestEngine::Engine.routes.draw do
  resources :memes, only: [:index, :show, :create, :update, :destroy]
end
