module Concerns
  module ExtendingConcern
    extend Apipie::DSL::Concern

    update_api(:create) do
      param :user, Hash do
        param :from_concern, String, :desc => 'param from concern', :allow_nil => false
      end
    end
  end
end
