Inline HTML at the beginning of a line shouldn't kill the rest of the line. https://github.com/bhollis/maruku/issues/67
*** Parameters: ***
{}
*** Markdown input: ***
<del>Two</del> Half
*** Output of inspect ***
md_el(:document, md_par([md_html("<del>Two</del>"), " Half"]))
*** Output of to_html ***
<p><del>Two</del> Half</p>

