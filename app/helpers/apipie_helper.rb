module ApipieHelper

  def heading(title, level=1)
    content_tag("h#{level}") do
      title
    end
  end

end
