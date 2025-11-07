Maruku should not mangle references that don't exist.
*** Parameters: ***
{:on_error=>:warning}
*** Markdown input: ***
Search on [Google images][ 	GoOgle search ]
*** Output of inspect ***
md_el(:document,[md_par(["Search on ", md_link(["Google images"]," \tGoOgle search ")])],{},[])
*** Output of to_html ***
<p>Search on [Google images][ 	GoOgle search ]</p>
*** Output of to_latex ***
Search on Google images
*** Output of to_md ***
Search on [Google images][ 	GoOgle search ]
*** Output of to_s ***
Search on Google images
