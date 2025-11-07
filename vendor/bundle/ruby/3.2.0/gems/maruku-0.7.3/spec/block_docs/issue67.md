A span at the beginning of a list item shouldn't cause the other list elements to be wrapped in paragraphs or remove the inline element. https://github.com/bhollis/maruku/issues/67
*** Parameters: ***
{}
*** Markdown input: ***
- One
- <del>Two</del>
- Three
*** Output of inspect ***
md_el(:document, md_el(:ul, [
	md_li("One", false),
	md_li(md_html("<del>Two</del>"), false),
	md_li("Three", false)
]))
*** Output of to_html ***
<ul>
  <li>One</li>
  <li><del>Two</del></li>
  <li>Three</li>
</ul>
