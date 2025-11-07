maruku treats all HTML as a block level element, but it should treat
inline elements as part of a paragraph, even if they start the line.
*** Parameters: ***
{} # params 
*** Markdown input: ***
<br/>123

*** Output of inspect ***
md_el(:document, md_par([md_html("<br />"), "123"]))
*** Output of to_html ***
<p><br/>123</p>
*** Output of to_latex ***

*** Output of to_md ***

*** Output of to_s ***

