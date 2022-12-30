# Service that builds the appropriate Apipie::MethodDescription::Api
# required by Apipie::MethodDescription
#
class Apipie::MethodDescription::ApisService
  # @param [Apipie::ResourceDescription] resource
  # @param [Symbol] controller_action
  # @param [Hash] dsl
  def initialize(resource, controller_action, dsl)
    @resource = resource
    @controller_action = controller_action
    @dsl = dsl
  end

  # @return [Array<Apipie::MethodDescription::Api>]
  def call
    api_args.map do |http_method, path, desc, opts|
      Apipie::MethodDescription::Api.new(
        http_method,
        concern_subst(path),
        concern_subst(desc),
        opts
      )
    end
  end

  private

  def concern_subst(path)
    return if path.blank?

    if from_concern?
      @resource.controller._apipie_perform_concern_subst(path)
    else
      path
    end
  end

  # @return [Array<Array>]
  def api_args
    return @dsl[:api_args] if !api_from_routes?

    api_args = @dsl[:api_args].dup

    api_args_from_routes = routes.map do |route_info|
      [
        route_info[:verb],
        route_info[:path],
        route_info[:desc],
        (route_info[:options] || {}).merge(from_routes: true)
      ]
    end

    api_args.concat(api_args_from_routes)
  end

  def api_from_routes?
    @dsl[:api_from_routes].present?
  end

  def from_concern?
    @dsl[:from_concern] == true
  end

  def description
    @dsl[:api_from_routes][:desc]
  end

  def options
    @dsl[:api_from_routes][:options]
  end

  # @return [Array<Hash>]
  def routes
    Apipie.routes_for_action(
      @resource.controller,
      @controller_action,
      { desc: description, options: options }
    )
  end
end


