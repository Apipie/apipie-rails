Non-ASCII characters in a PRE tag. See https://github.com/bhollis/maruku/issues/79
*** Parameters: ***
{}
*** Markdown input: ***
<p>á é í ó ú</p>

<pre>
á é í ó ú
</pre>
*** Output of inspect ***
md_el(:document, [md_html("<p>á é í ó ú</p>"), md_html("<pre>\ná é í ó ú\n</pre>")])
*** Output of to_html ***
<p>á é í ó ú</p><pre>
á é í ó ú
</pre>
