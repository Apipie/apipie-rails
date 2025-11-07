Header levels go up to 6. More #'s is not a header (see Commonmark Spec).
*** Parameters: ***
{}
*** Markdown input: ***
#### A header ####

######## Not a header ########


*** Output of inspect ***
md_el(:document,[
	md_el(:header, "A header", {:level=>4}, []),
	md_par("######## Not a header ########", [])
],{},[])
*** Output of to_html ***
<h4 id="a_header">A header</h4>

<p>######## Not a header ########</p>
*** Output of to_latex ***
\hypertarget{a_header}{}\paragraph*{{A header}}\label{a_header}

\#\#\#\#\#\#\#\# Not a header \#\#\#\#\#\#\#\#