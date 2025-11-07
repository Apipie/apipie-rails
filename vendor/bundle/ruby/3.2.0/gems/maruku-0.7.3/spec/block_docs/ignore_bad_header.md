Pass weird messed up header through to output without blowing up. Secondary issue noticed via https://github.com/bhollis/maruku/issues/124
*** Parameters: ***
{:on_error => :raise}
*** Markdown input: ***
= Markdown, with some ruby =
*** Output of inspect ***
md_el(:document, md_par(["= Markdown, with some ruby ="]))
*** Output of to_html ***
<p>= Markdown, with some ruby =</p>
