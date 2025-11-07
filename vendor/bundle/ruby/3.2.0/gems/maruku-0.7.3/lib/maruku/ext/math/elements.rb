module MaRuKu
  class MDElement
    def md_inline_math(math)
      self.md_el(:inline_math, [], :math => math)
    end

    def md_equation(math, label, numerate)
      reglabel = /\\label\{(\w+)\}/
      math = math.gsub(reglabel, '') if label = math[reglabel, 1]
      num = nil
      if (label || numerate) && @doc # take number
        @doc.eqid2eq ||= {}
        num = @doc.eqid2eq.size + 1
        label = "eq#{num}" unless label # TODO do id for document
      end
      e = self.md_el(:equation, [], :math => math, :label => label, :num => num)
      @doc.eqid2eq[label] = e if label && @doc # take number
      e
    end
  end
end
