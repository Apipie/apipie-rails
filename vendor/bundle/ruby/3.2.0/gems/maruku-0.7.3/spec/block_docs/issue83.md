Maruku confused by HTML that contains @ signs. See https://github.com/bhollis/maruku/issues/83
*** Parameters: ***
{}
*** Markdown input: ***
<div><span>@Foo</span>

</div>
*** Output of inspect ***
md_el(:document, md_html("<div><span>@Foo</span>\n\n</div>"))
*** Output of to_html ***
<div><span>@Foo</span>

</div>