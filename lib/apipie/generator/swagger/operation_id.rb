class Apipie::Generator::Swagger::OperationId
  def initialize(path:, http_method:, param: nil)
    @path = path
    @http_method = http_method
    @param = param
  end

  # @return [String]
  def to_s
    base = normalized_http_method + path

    if @param.present?
      "#{base}_param_#{@param}"
    else
      base
    end
  end

  # @param [Apipie::MethodDescription::Api, Apipie::MethodDescription] describable
  # @param [String, Symbol, nil] param
  #
  # @return [Apipie::Generator::Swagger::OperationId]
  def self.from(describable, param: nil)
    path, http_method =
      if describable.respond_to?(:path) && describable.respond_to?(:http_method)
        [describable.path, describable.http_method]
      elsif describable.is_a?(Apipie::MethodDescription)
        [describable.apis.first.path, describable.apis.first.http_method]
      end

    new(path: path, http_method: http_method, param: param)
  end

  private

  # Converts an http path for example `/api/concerns/:id` to `_api_concerns_id`
  #
  # @return [String]
  def path
    @path.gsub(%r{/}, '_').gsub(/:(\w+)/, '\1').gsub(/_$/, '')
  end

  # Converts an http method like `GET` to `get` Using lowercase http method,
  #   because the 'swagger-codegen' tool outputs strange method names if the
  #   http method is in uppercase
  #
  # @return [String]
  def normalized_http_method
    @http_method.to_s.downcase
  end
end
