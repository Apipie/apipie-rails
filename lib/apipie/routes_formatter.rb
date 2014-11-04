class RoutesFormater
  API_METHODS = %w{GET POST PUT PATCH OPTIONS DELETE}

  def self.format_paths(rails_paths)
    rails_paths.map { |rails_path| format_path(rails_path) }
  end

  def self.format_path(rails_path)
    path = if Rails::VERSION::STRING < '3.2.0'
             rails_path.path.to_s
           else
             rails_path.path.spec.to_s
           end

    path = Apipie.configuration.routes_path_formatter.call(path)

    { path: path, verb: human_verb(rails_path) }
  end

  def self.human_verb(route)
    verb = API_METHODS.select{|defined_verb| defined_verb =~ /\A#{route.verb}\z/}
    if verb.count != 1
      verb = API_METHODS.select{|defined_verb| defined_verb == route.constraints[:method]}
      if verb.blank?
        raise "Unknow verb #{route.path.spec.to_s}"
      end
    end
    verb.first
  end
end