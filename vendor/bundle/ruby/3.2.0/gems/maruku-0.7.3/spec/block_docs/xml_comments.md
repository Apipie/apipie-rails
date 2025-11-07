XML Comments need to be handled properly.
Note that output is kind of weird because we modify the comment in order to let REXML parse it due to https://bugs.ruby-lang.org/issues/9277.
*** Parameters: ***
{}
*** Markdown input: ***
<!--
&rsquo;
-->

<!-- declarations for <head> & <body> -->

<!-- -- is invalid -->

<!-- -- is
invalid -->

*** Output of inspect ***
md_el(:document,[md_html("<!--\n&rsquo;\n-->"),
	md_html("<!-- declarations for <head> & <body> -->"),
	md_html("<!-- - - is invalid -->"),
	md_html("<!-- - - is\ninvalid -->")])
*** Output of to_html ***
<!--
&rsquo;
-->

<!-- declarations for <head> & <body> -->

<!-- - - is invalid -->

<!-- - - is
invalid -->
