Markdown should be processed inside span-level tags. https://github.com/bhollis/maruku/issues/31
*** Parameters: ***
{}
*** Markdown input: ***
<span>*hello*</span>

<p><span>*hello*</span></p>

<span>hello <span>*there*</span></span>

<span>hello
<span>*there*</span></span>
*** Output of inspect ***
md_el(:document, [
  md_par(md_html("<span>*hello*</span>")),
  md_html("<p><span>*hello*</span></p>"),
  md_par(md_html("<span>hello <span>*there*</span></span>")),
  md_par(md_html("<span>hello\n<span>*there*</span></span>"))
])
*** Output of to_html ***
<p><span><em>hello</em></span></p>
<p><span>*hello*</span></p>
<p><span>hello <span><em>there</em></span></span></p>
<p><span>hello
<span><em>there</em></span></span></p>