module Apipie
  class RoutesFormatter
    API_METHODS = %w{GET POST PUT PATCH OPTIONS DELETE}

    # The entry method called by Apipie to extract the array
    # representing the api dsl from the routes definition.
    def format_routes(rails_routes, args)
      rails_routes.map { |rails_route| format_route(rails_route, args) }
    end

    def format_route(rails_route, args)
      { :path => format_path(rails_route),
        :verb => format_verb(rails_route),
        :desc => args[:desc],
        :options => args[:options] }
    end

    def format_path(rails_route)
      rails_route.path.spec.to_s.gsub('(.:format)', '')
    end

    def format_verb(rails_route)
      verb = API_METHODS.select{|defined_verb| defined_verb =~ /\A#{rails_route.verb}\z/}
      if verb.count != 1
        verb = API_METHODS.select{|defined_verb| defined_verb == rails_route.constraints[:method]}
        if verb.blank?
          raise "Unknow verb #{rails_route.path.spec.to_s}"
        end
      end
      verb.first
    end
  end
end
