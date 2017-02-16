Dummy::Application.routes.draw do

  scope ENV['RAILS_RELATIVE_URL_ROOT'] || '/' do

    scope '/api' do
      resources :users do
        collection do
          post :create_route
        end
      end
      resources :concerns, :only => [:index, :show]
      namespace :files do
        get '/*file_path', format: false, :action => 'download'
      end
      resources :twitter_example do
        collection do
          get :lookup
          get 'profile_image/:screen_name' => 'twitter_example#profile_image'
          get :search
          get :search
          get :contributors
        end
      end
    end

    apipie
  end
  root :to => 'apipie/apipies#index'
  match '(/)*path' => redirect('http://www.example.com'), :via => :all
end
