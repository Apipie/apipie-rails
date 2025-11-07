Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
See [foo' bar][foo_bar]

[foo_bar]: http://agorf.gr/


*** Output of inspect ***
md_el(:document,[ md_par([ "See ", md_link(["foo", md_entity("rsquo"), " bar"],"foo_bar")]),
	md_ref_def("foo_bar", "http://agorf.gr/", {:title=>nil})
],{},[])
*** Output of to_html ***
<p>See <a href="http://agorf.gr/">foo’ bar</a></p>
*** Output of to_latex ***
See \href{http://agorf.gr/}{foo' bar}
*** Output of to_md ***
See foo bar
*** Output of to_s ***
See foo bar
