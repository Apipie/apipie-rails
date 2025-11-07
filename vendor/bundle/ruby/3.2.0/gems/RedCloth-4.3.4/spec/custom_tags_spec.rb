require File.dirname(__FILE__) + '/spec_helper'

module FigureTag
  def fig( opts )
    label, img = opts[:text].split('|').map! {|str| str.strip}

    html  = %Q{<div class="img" id="figure-#{label.tr('.', '-')}">\n}.dup
    html << %Q{  <a class="fig" href="/images/#{img}">\n}
    html << %Q{    <img src="/images/thumbs/#{img}" alt="Figure #{label}" />\n}
    html << %Q{  </a>\n}
    html << %Q{  <p>Figure #{label}</p>\n}
    html << %Q{<div>\n}
  end
end

describe "custom tags" do
  it "should recognize the custom tag" do
    input  = %Q{The first line of text.\n\n}.dup
    input << %Q{fig. 1.1 | img.jpg\n\n}
    input << %Q{The last line of text.\n}
    r = RedCloth.new input
    r.extend FigureTag

    html  = %Q{<p>The first line of text.</p>\n}.dup
    html << %Q{<div class="img" id="figure-1-1">\n}
    html << %Q{  <a class="fig" href="/images/img.jpg">\n}
    html << %Q{    <img src="/images/thumbs/img.jpg" alt="Figure 1.1" />\n}
    html << %Q{  </a>\n}
    html << %Q{  <p>Figure 1.1</p>\n}
    html << %Q{<div>\n}
    html << %Q{<p>The last line of text.</p>}
    
    expect(r.to_html).to eq(html)
  end

  it "should fall back if custom tag isn't defined" do
    r = RedCloth.new %Q/fig()>[no]{color:red}. 1.1 | img.jpg/
    
    expect(r.to_html).to eq("<p>fig()>[no]{color:red}. 1.1 | img.jpg</p>")
  end
  
  it "should not call just regular string methods" do
    r = RedCloth.new "next. "
    r.extend FigureTag

    html  = "<p>next. </p>"

    expect(r.to_html).to eq(html)
  end
end
