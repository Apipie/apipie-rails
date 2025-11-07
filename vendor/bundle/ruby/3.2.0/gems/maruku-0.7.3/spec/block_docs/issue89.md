https://github.com/bhollis/maruku/issues/89 - Markdown extra .class ALD parsing error
*** Parameters: ***
{}
*** Markdown input: ***

[![Alt text](/Understanding-Big-Data-Cover-201x300.jpg){.alignright}](http://testsite.com/big-data)

*** Output of inspect ***
md_el(:document,
  md_par(md_im_link(md_im_image("Alt text", "/Understanding-Big-Data-Cover-201x300.jpg", nil, [[:class, "alignright"]]), "http://testsite.com/big-data", nil)))
*** Output of to_html ***
<p><a href="http://testsite.com/big-data"><img class="alignright" src="/Understanding-Big-Data-Cover-201x300.jpg" alt="Alt text" /></a></p>
