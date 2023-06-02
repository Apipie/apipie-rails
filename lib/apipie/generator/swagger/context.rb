class Apipie::Generator::Swagger::Context
  attr_reader :default_in_value, :language, :http_method, :controller_method,
              :prefix

  def initialize(
    allow_null:,
    http_method:,
    controller_method:,
    prefix: nil,
    default_in_value: nil,
    language: nil,
    in_schema: true
  )
    @default_in_value = default_in_value
    @allow_null = allow_null
    @language = language
    @in_schema = in_schema
    @http_method = http_method
    @controller_method = controller_method
    @prefix = prefix
  end

  def allow_null?
    @allow_null == true
  end

  def in_schema?
    @in_schema == true
  end

  def add_to_prefix!(prefix)
    @prefix = if @prefix.present?
                "#{@prefix}[#{prefix}]"
              else
                prefix
              end
  end
end
