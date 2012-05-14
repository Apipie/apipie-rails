module Restapi
  module RestapisHelper

  def print_nested_params(param, level=0)
    content = ''

    unless param[:params].blank?
      param[:params].each do |val|
        col = 255 - level*5
        content << "<tr style='background-color:rgb(#{col},#{col},#{col});'><td>"
        content << ("<strong>#{val[:full_name]}</strong><br>")
        content << "<small>"
        content << (val[:required] ? 'required' : 'optional')
        content << (val[:allow_nil] ? ', nil allowed' : '')
        content << "</small>"
        content << "</td><td>"
        content << val[:description].html_safe
        content << "<br>"
        unless val[:validator].blank?
          content << "Value: #{val[:validator]}"
        end
        content << "</td></tr>"

        content << print_nested_params(val, level+1) unless val[:params].blank?
      end
    end
    content.html_safe
  end

  end
end