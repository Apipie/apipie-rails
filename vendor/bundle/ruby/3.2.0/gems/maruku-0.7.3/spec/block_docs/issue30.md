List markers typically start at the left margin, but may be indented by up to three spaces. https://github.com/bhollis/maruku/issues/30
*** Parameters: ***
{}
*** Markdown input: ***
This is a list:

  * a list

And this:

   * still a list
*** Output of inspect ***
md_el(:document, [
	md_par("This is a list:"),
	md_el(:ul, md_el(:li, "a list", {:want_my_paragraph=>false})),
	md_par("And this:"),
	md_el(:ul, md_el(:li, "still a list", {:want_my_paragraph=>false}))
])
*** Output of to_html ***
<p>This is a list:</p>

<ul>
<li>a list</li>
</ul>

<p>And this:</p>

<ul>
<li>still a list</li>
</ul>
