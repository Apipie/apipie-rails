module MaRuKu
  class MDDocument
    # A hash of equation ids to equation elements
    #
    # @return [String => MDElement]
    attr_accessor :eqid2eq

    def is_math_enabled?
      get_setting :math_enabled
    end
  end
end

# TODO: Properly scope all these regexps
# Everything goes; takes care of escaping the "\$" inside the expression
RegInlineMath = /\${1}((?:[^\$]|\\\$)+)\$/

MaRuKu::In::Markdown.register_span_extension(
  :chars => '$',
  :regexp => RegInlineMath,
  :handler => lambda do |doc, src, con|
    next false unless doc.is_math_enabled?
    next false unless m = src.read_regexp(RegInlineMath)
    math = m.captures.compact.first
    con.push doc.md_inline_math(math)
    true
  end)


MathOpen1 = Regexp.escape('\\begin{equation}')
MathClose1 = Regexp.escape('\\end{equation}')
MathOpen2 = Regexp.escape('\\[')
MathClose2 = Regexp.escape('\\]')
MathOpen3 = Regexp.escape('$$')
MathClose3 = Regexp.escape('$$')

EqLabel = /(?:\((\w+)\))/
EquationOpen = /#{MathOpen1}|#{MathOpen2}|#{MathOpen3}/
EquationClose = /#{MathClose1}|#{MathClose2}|#{MathClose3}/

# $1 is opening, $2 is tex
EquationStart = /^[ ]{0,3}(#{EquationOpen})(.*)$/
# $1 is tex, $2 is closing, $3 is tex
EquationEnd = /^(.*)(#{EquationClose})\s*#{EqLabel}?\s*$/
# $1 is opening, $2 is tex, $3 is closing, $4 is label
OneLineEquation = /^[ ]{0,3}(#{EquationOpen})(.*)(#{EquationClose})\s*#{EqLabel}?\s*$/

MaRuKu::In::Markdown.register_block_extension(
  :regexp  => EquationStart,
  :handler => lambda do |doc, src, con|
    next false unless doc.is_math_enabled?
    first = src.shift_line
    if first =~ OneLineEquation
      opening, tex, closing, label = $1, $2, $3, $4
      numerate = doc.get_setting(:math_numbered).include?(opening)
      con.push doc.md_equation(tex, label, numerate)
      next true
    end

    opening, tex = first.scan(EquationStart).first
    # ensure newline at end of first line of equation isn't swallowed
    tex << "\n"
    numerate = doc.get_setting(:math_numbered).include?(opening)
    label = nil
    loop do
      unless src.cur_line
        doc.maruku_error(
          "Stream finished while reading equation\n\n" + tex.gsub(/^/, '$> '),
          src, con)
        break
      end

      line = src.shift_line
      if line =~ EquationEnd
        tex_line, closing = $1, $2
        label = $3 if $3
        tex << tex_line << "\n"
        break
      end

      tex << line << "\n"
    end
    con.push doc.md_equation(tex, label, numerate)
    true
  end)


# This adds support for \eqref
RegEqrefLatex = /\\eqref\{(\w+?)\}/
RegEqPar = /\(eq:(\w+?)\)/
RegEqref = Regexp.union(RegEqrefLatex, RegEqPar)

MaRuKu::In::Markdown.register_span_extension(
  :chars => ["\\", '('],
  :regexp => RegEqref,
  :handler => lambda do |doc, src, con|
    return false unless doc.is_math_enabled?
    eqid = src.read_regexp(RegEqref).captures.compact.first
    con.push doc.md_el(:eqref, [], :eqid => eqid)
    true
  end)

# This adds support for \ref
RegRef = /\\ref\{(\w*?)\}/
MaRuKu::In::Markdown.register_span_extension(
  :chars => ["\\"],
  :regexp => RegRef,
  :handler => lambda do |doc, src, con|
    return false unless doc.is_math_enabled?
    refid = src.read_regexp(RegRef).captures.compact.first
    con.push doc.md_el(:divref, [], :refid => refid)
    true
  end)

# This adds support for \cite
RegCite = /\\cite\{([^}]*?)\}/
MaRuKu::In::Markdown.register_span_extension(
  :chars => ["\\"],
  :regexp => RegCite,
  :handler => lambda do |doc, src, con|
    return false unless doc.is_math_enabled?
    cites = src.read_regexp(RegCite).captures.compact.first.split(/\s*,\s*/)
    con.push doc.md_el(:citation, [], :cites => cites)
    true
  end)
