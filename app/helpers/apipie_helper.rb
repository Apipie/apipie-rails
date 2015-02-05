module ApipieHelper

  def heading(title, level=1)
    content_tag("h#{level}") do
      title
    end
  end

  def format_example_data(data)
    case data
    when Array, Hash
      JSON.pretty_generate(data).gsub(/: \[\s*\]/,": []").gsub(/\{\s*\}/,"{}")
    else
      data
    end
  end

end
