class RoutesFormater
  API_METHODS = %w{GET POST PUT PATCH OPTIONS DELETE}

  class Path
    def format(rails_path_spec)
      rails_path_spec
    end
  end

  def initialize
    @path_formatter = Path.new
  end

  def format_paths(rails_paths)
    rails_paths.map { |rails_path| format_path(rails_path) }
  end

  def format_path(rails_path)
    path = @path_formatter.format(rails_path.path.spec.to_s)

    { path: path, verb: human_verb(rails_path) }
  end

  def human_verb(route)
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