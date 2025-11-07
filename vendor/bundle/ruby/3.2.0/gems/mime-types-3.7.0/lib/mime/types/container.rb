# frozen_string_literal: true

require "set"

# MIME::Types requires a serializable keyed container that returns an empty Set
# on a key miss. Hash#default_value cannot be used because, while it traverses
# the Marshal format correctly, it will not survive any other serialization
# format (plus, a default of a mutable object resuls in a shared mess).
# Hash#default_proc cannot be used without a wrapper because it prevents
# Marshal serialization (and does not survive the round-trip).
class MIME::Types::Container # :nodoc:
  def initialize(hash = {})
    @container = {}
    merge!(hash)
  end

  def [](key)
    container[key] || EMPTY_SET
  end

  def []=(key, value)
    container[key] =
      case value
      when Set
        value
      else
        Set[*value]
      end
  end

  def merge(other)
    self.class.new(other)
  end

  def merge!(other)
    tap {
      other = other.is_a?(MIME::Types::Container) ? other.container : other
      container.merge!(other)
      normalize
    }
  end

  def to_hash
    container
  end

  def ==(other)
    container == other
  end

  def count(*args, &block)
    if args.size == 0
      container.count
    elsif block
      container.count(&block)
    else
      container.count(args.first)
    end
  end

  def each_pair(&block)
    container.each_pair(&block)
  end

  alias_method :each, :each_pair

  def each_value(&block)
    container.each_value(&block)
  end

  def empty?
    container.empty?
  end

  def flat_map(&block)
    container.flat_map(&block)
  end

  def keys
    container.keys
  end

  def values
    container.values
  end

  def select(&block)
    container.select(&block)
  end

  def add(key, value)
    (container[key] ||= Set.new).add(value)
  end

  def marshal_dump
    {}.merge(container)
  end

  def marshal_load(hash)
    @container = hash
  end

  def encode_with(coder)
    container.each { |k, v| coder[k] = v.to_a }
  end

  def init_with(coder)
    @container = {}
    coder.map.each { |k, v| container[k] = Set[*v] }
  end

  protected

  attr_accessor :container

  def normalize
    container.each do |k, v|
      next if v.is_a?(Set)

      container[k] = Set[*v]
    end
  end

  EMPTY_SET = Set.new.freeze
  private_constant :EMPTY_SET
end
