Lines should be able to start with @. Note that a leading space doesn't
trigger the old metadata syntax. https://github.com/bhollis/maruku/issues/70
*** Parameters: ***
{}
*** Markdown input: ***
@ foo
*** Output of inspect ***
md_el(:document, md_par("@ foo"))
*** Output of to_html ***
<p>@ foo</p>

