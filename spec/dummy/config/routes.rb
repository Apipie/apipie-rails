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

      # This is not directly used in the specs.
      # It is only there to tests apipies tolerance regarding
      # missing controllers.
      resources :dangeling_stuff
      resources :twitter_example do
        collection do
          get :lookup
          get 'profile_image/:screen_name' => 'twitter_example#profile_image'
          get :search
          get :search
          get :contributors
        end
      end

      get "/pets/return_and_validate_expected_response" => "pets#return_and_validate_expected_response"
      get "/pets/return_and_validate_expected_array_response" => "pets#return_and_validate_expected_array_response"
      get "/pets/return_and_validate_type_mismatch" => "pets#return_and_validate_type_mismatch"
      get "/pets/return_and_validate_missing_field" => "pets#return_and_validate_missing_field"
      get "/pets/return_and_validate_extra_property" => "pets#return_and_validate_extra_property"
      get "/pets/return_and_validate_allowed_extra_property" => "pets#return_and_validate_allowed_extra_property"
      get "/pets/sub_object_invalid_extra_property" => "pets#sub_object_invalid_extra_property"
      get "/pets/sub_object_allowed_extra_property" => "pets#sub_object_allowed_extra_property"
      get "/pets/return_and_validate_unexpected_array_response" => "pets#return_and_validate_unexpected_array_response"
      get "/pets/return_and_validate_expected_response_with_null" => "pets#return_and_validate_expected_response_with_null"
      get "/pets/return_and_validate_expected_response_with_null_object" => "pets#return_and_validate_expected_response_with_null_object"

      get "/pets/returns_response_with_valid_array" => "pets#returns_response_with_valid_array"
      get "/pets/returns_response_with_invalid_array" => "pets#returns_response_with_invalid_array"
      get "/pets/undocumented_method" => "pets#undocumented_method"
    end

    apipie
  end
  root :to => 'apipie/apipies#index'
  match '(/)*path' => redirect('http://www.example.com'), :via => :all
end
