class ConcernsController < ApplicationController

  resource_description { resource_id 'concern_resources' }

  apipie_concern_subst(:concern => 'user', :custom_subst => 'custom', 'string_subst' => 'string')
  include ::Concerns::SampleController

end
