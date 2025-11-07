Generating ids for unicode headers. Other markdown implementations drop the non-ASCII characters so the anchor is URL-valid. https://github.com/bhollis/maruku/issues/29
*** Parameters: ***
{}
*** Markdown input: ***
# Übersicht
*** Output of inspect ***
md_el(:document, md_el(:header, "Übersicht", {:level=>1}))
*** Output of to_html ***
<h1 id='bersicht'>Übersicht</h1>
