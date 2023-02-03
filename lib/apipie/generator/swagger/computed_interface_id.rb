# The {Apipie::Generator::Swagger::ComputedInterfaceId.id} is a number that is
# uniquely derived from the list of operations added to the swagger definition (in an order-dependent way).
# it can be used for regression testing, allowing some differentiation between changes that
# result from changes to the input and those that result from changes to the generation
# algorithms.
#
# @note At the moment, this only takes operation ids into account, and ignores
# parameter definitions, so it's only partially useful.
class Apipie::Generator::Swagger::ComputedInterfaceId
  include Singleton

  def initialize
    @computed_interface_id = 0
  end

  def add!(operation_id)
    @computed_interface_id = Zlib.crc32("#{@computed_interface_id} #{operation_id}")
  end

  def id
    @computed_interface_id
  end
end
