Dummy::Application.routes.draw do
  
  scope ENV['RAILS_RELATIVE_URL_ROOT'] || '/' do
    
    resources :users do
      collection do
        get :doc
      end
    end
  
    resources :dogs
    resources :twitter_example

    restapi
  end
end
