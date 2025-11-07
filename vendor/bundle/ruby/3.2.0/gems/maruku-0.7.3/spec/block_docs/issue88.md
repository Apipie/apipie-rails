HTML tags get chomped in list. See https://github.com/bhollis/maruku/issues/88
*** Parameters: ***
{}
*** Markdown input: ***
<span> hello </span>

1. <span> world </span>

*** Output of inspect ***
md_el(:document, [md_par(md_html("<span> hello </span>")),
        md_el(:ol, md_li(md_html("<span> world </span>"), false))
])
*** Output of to_html ***
<p><span> hello </span>
</p>
<ol>
    <li><span> world </span>
    </li>
</ol>