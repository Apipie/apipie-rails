Nested list with a single item. https://github.com/bhollis/maruku/issues/64
*** Parameters: ***
{}
*** Markdown input: ***
A nested list with a single item (does not work)

- three items:
  - item 1
  - item 2
  - item 3
- one item:
  - item
- two items:
  - item a
  - item b

*** Output of inspect ***
md_el(:document, [
	md_par("A nested list with a single item (does not work)"),
	md_el(:ul, [
	md_li([
	"three items:",
	md_el(:ul, [
	md_li("item 1", false),
	md_li("item 2", false),
	md_li("item 3", false)
])
], false),
	md_li(["one item:", md_el(:ul, md_li("item", false))], false),
	md_li([
	"two items:",
	md_el(:ul, [md_li("item a", false), md_li("item b", false)])
], false)
])
])
*** Output of to_html ***
<p>A nested list with a single item (does not work)</p>

<ul>
<li>three items:
<ul>
<li>item 1</li>
<li>item 2</li>
<li>item 3</li>
</ul></li>
<li>one item:
<ul>
<li>item</li>
</ul></li>
<li>two items:
<ul>
<li>item a</li>
<li>item b</li>
</ul></li>
</ul>
