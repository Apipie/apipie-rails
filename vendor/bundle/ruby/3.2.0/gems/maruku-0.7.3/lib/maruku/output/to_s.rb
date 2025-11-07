module MaRuKu

  class MDElement

    # Strips all formatting from the string
    def to_s
      children_to_s
    end

    def children_to_s
      @children.join
    end
  end
end
