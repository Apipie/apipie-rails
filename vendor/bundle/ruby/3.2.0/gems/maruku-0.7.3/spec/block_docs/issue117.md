Section tags should not get <p> put around them. https://github.com/bhollis/maruku/issues/117
*** Parameters: ***
{}
*** Markdown input: ***
<section markdown="1">
## Header
</section>
*** Output of inspect ***

*** Output of to_html ***
<section>
<h2>Header</h2>
</section>
