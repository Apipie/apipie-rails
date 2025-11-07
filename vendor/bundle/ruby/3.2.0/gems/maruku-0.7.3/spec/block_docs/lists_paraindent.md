Indentation is weird...
*** Parameters: ***
{} # params 
*** Markdown input: ***
*   A list item
    * Foo
    * Bar
      * Bax
    Bap
*   Another list item
*** Output of inspect ***
md_el(:document, md_el(:ul, [
	md_li([
	"A list item",
	md_el(:ul, [
	md_li("Foo", false),
	md_li([
	"Bar",
	md_el(:ul, [
	md_li("Bax Bap", false)
])
], false)
])
], false),
	md_li("Another list item", false)
]))
*** Output of to_html ***
<ul>
<li>A list item
<ul>
<li>Foo</li>

<li>Bar
<ul>
<li>Bax Bap</li>
</ul>
</li>
</ul>
</li>

<li>Another list item</li>
</ul>
