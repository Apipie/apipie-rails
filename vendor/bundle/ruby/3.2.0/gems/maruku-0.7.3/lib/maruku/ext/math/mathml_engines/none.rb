module MaRuKu::Out::HTML
  def convert_to_mathml_none(kind, tex)
    code = xelem('code')
    tex_node = xtext(tex)
    code << tex_node
  end

  def convert_to_png_none(kind, tex)
    nil
  end
end

