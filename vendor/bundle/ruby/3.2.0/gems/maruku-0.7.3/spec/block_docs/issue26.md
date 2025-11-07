Nested lists shouldn't get <p> tags wrapped around elements. https://github.com/bhollis/maruku/issues/26
*** Parameters: ***
{}
*** Markdown input: ***
 -  Root
     +  Node
     +  Node
 -  Root
*** Output of inspect ***
md_el(:document, md_el(:ul, [
	md_li(["Root", md_el(:ul, [md_li("Node", false), md_li("Node", false)])], false),
	md_li("Root", false)
]))
*** Output of to_html ***
<ul>
<li>Root
<ul>
<li>Node</li>
<li>Node</li>
</ul></li>
<li>Root</li>
</ul>
