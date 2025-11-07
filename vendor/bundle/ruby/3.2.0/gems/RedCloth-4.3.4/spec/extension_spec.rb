require File.dirname(__FILE__) + '/spec_helper'

# http://www.ralree.info/2006/9/13/extending-redcloth
module RedClothSmileyExtension
  def refs_smiley(text)
    text.gsub!(/(\s)~(:P|:D|:O|:o|:S|:\||;\)|:'\(|:\)|:\()/) do |m|
      bef,ma = $~[1..2]
      filename = "/images/emoticons/"+(ma.unpack("c*").join('_'))+".png"
      "#{bef}<img src='#{filename}' title='#{ma}' class='smiley' />"
    end
  end
end

RedCloth.send(:include, RedClothSmileyExtension)

describe RedClothSmileyExtension do
  
  it "should include the extension" do
    input  = %Q{You're so silly! ~:P}

    html  = %Q{<p>You&#8217;re so silly! <img src='/images/emoticons/58_80.png' title=':P' class='smiley' /></p>}

    expect(RedCloth.new(input).to_html(:textile, :refs_smiley)).to eq(html)
  end
  
end