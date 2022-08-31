module RandomParamGroup
  def self.included(klazz)
    klazz.def_param_group :random_param_group do
      property :id, Integer
      property :name, String
    end
  end
end
