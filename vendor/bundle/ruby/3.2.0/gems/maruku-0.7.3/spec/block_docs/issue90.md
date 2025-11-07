https://github.com/bhollis/maruku/issues/90 - TOC not working without an H1 on the page.
*** Parameters: ***
{:use_numbered_headers => true}
*** Markdown input: ***

* Table of contents
{:toc}

## First Heading

Foo

## Second Heading

### Subheading

Foobar

*** Output of inspect ***
md_el(:document,[
	md_el(:ul, md_li("Table of contents", false), {}, [[:ref, "toc"]]),
	md_el(:header, "First Heading", {:level=>2}),
	md_par("Foo"),
	md_el(:header, "Second Heading", {:level=>2}),
	md_el(:header, "Subheading", {:level=>3}),
	md_par("Foobar")
],{},[])
*** Output of to_html ***
<div class="maruku_toc"><ul><li><span class="maruku_section_number">1. </span><a href="#first_heading">First Heading</a></li><li><span class="maruku_section_number">2. </span><a href="#second_heading">Second Heading</a><ul><li><span class="maruku_section_number">2.1. </span><a href="#subheading">Subheading</a></li></ul></li></ul></div>
<h2 id="first_heading"><span class="maruku_section_number">1. </span>First Heading</h2>

<p>Foo</p>

<h2 id="second_heading"><span class="maruku_section_number">2. </span>Second Heading</h2>

<h3 id="subheading"><span class="maruku_section_number">2.1. </span>Subheading</h3>

<p>Foobar</p>
