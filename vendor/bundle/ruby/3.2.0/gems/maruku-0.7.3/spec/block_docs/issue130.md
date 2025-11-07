Handle ellipsis at the end of a line. https://github.com/bhollis/maruku/issues/130
*** Parameters: ***
{ }
*** Markdown input: ***
A paragraph... continued...
*** Output of inspect ***
md_el(:document, md_par(["A paragraph", md_entity("hellip"), " continued", md_entity("hellip")]))
*** Output of to_html ***
<p>A paragraph… continued…</p>
*** Output of to_latex ***
A paragraph\ldots{} continued\ldots{}
