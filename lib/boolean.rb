class Boolean

  def self.new(bool)
    bool
  end

  def self.true
    true
  end

  def self.false
    false
  end

end

class FalseClass

  def is_a?(other)
    other == Boolean || super
  end

  def self.===(other)
    other == Boolean || super
  end

end

class TrueClass

  def is_a?(other)
    other == Boolean || super
  end

  def self.===(other)
    other == Boolean || super
  end

end
