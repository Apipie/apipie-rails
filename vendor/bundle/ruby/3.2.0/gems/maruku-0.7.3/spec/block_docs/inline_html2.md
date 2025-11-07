Markdown inside HTML according to Markdown Extra: http://michelf.ca/projects/php-markdown/extra/#markdown-attr
*** Parameters: ***
{}
*** Markdown input: ***
<div markdown="1">Test **bold**</div>
<p markdown="1">Test **bold**</p>
*** Output of inspect ***
md_el(:document,[
	md_html("<div markdown=\"1\">Test **bold**</div>"),
	md_html("<p markdown=\"1\">Test **bold**</p>")
],{},[])
*** Output of to_html ***
<div>
<p>Test <strong>bold</strong></p>
</div><p>Test <strong>bold</strong></p>
*** Output of to_latex ***

*** Output of to_md ***

*** Output of to_s ***

