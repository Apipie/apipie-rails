Dummy::Application.routes.draw do

  scope ENV['RAILS_RELATIVE_URL_ROOT'] || '/' do

    scope '/api' do
      resources :users do
        collection do
          post :create_route => 'users#create_route'
        end
      end
      resources :concerns, :only => [:index, :show]
      namespace :files do
        get '/*file_path' => 'files#download', format: false
      end
      resources :twitter_example do
        collection do
          get :lookup => 'twitter_example#lookup'
          get 'profile_image/:screen_name' => 'twitter_example#profile_image'
          get :search => 'twitter_example#search'
          get :search => 'twitter_example#search'
          get :contributors => 'twitter_example#contributors'
        end
      end
    end

    apipie
  end
  root :to => 'apipie/apipies#index'
  match '(/)*path' => redirect('http://www.example.com'), :via => :all
end
