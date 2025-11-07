Maruku should not nest block-level HTML inside a paragraph
*** Parameters: ***
{} # params
*** Markdown input: ***
One
<div>a</div>123

<div>a</div>123
*** Output of inspect ***
md_el(:document,[
	md_par("One"),
  md_html("<div>a</div>"),
  md_par("123"),
	md_html("<div>a</div>"),
  md_par("123")
],{},[])
*** Output of to_html ***
<p>One</p>
<div>a</div>
<p>123</p>
<div>a</div>
<p>123</p>
