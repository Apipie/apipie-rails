Markdown should be processed trailing text after HTML
*** Parameters: ***
{}
*** Markdown input: ***
before

<!-- comment --> ------

after

<p>hello</p> *foo*

done
*** Output of inspect ***
md_el(:document, [
       md_par("before"),
       md_html("<!-- comment -->"),
       md_el(:hrule, []),
       md_par("after"),
       md_html("<p>hello</p>"),
       md_par(md_em("foo")),
       md_par("done") ])
*** Output of to_html ***
<p>before</p>
<!-- comment --><hr />

<p>after</p>
<p>hello</p>
<p><em>foo</em></p>

<p>done</p>