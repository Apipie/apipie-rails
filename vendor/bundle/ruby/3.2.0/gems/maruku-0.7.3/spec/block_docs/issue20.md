Just an attribute list on its own in a header is probably really content. https://github.com/bhollis/maruku/issues/20
*** Parameters: ***
{}
*** Markdown input: ***
# {hi}
*** Output of inspect ***
md_el(:document, md_el(:header, "{hi}", {:level=>1}))
*** Output of to_html ***
<h1 id="hi">{hi}</h1>
