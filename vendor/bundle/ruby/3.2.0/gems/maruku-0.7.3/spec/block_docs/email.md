Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***


This is an email address: <andrea@invalid.it>
	
Address: <andrea@invalid.it>
*** Output of inspect ***
md_el(:document,[
        md_par(["This is an email address: ", md_email("andrea@invalid.it")]),
        md_par(["Address: ", md_email("andrea@invalid.it")])
],{},[])
*** Output of to_html ***
<p>This is an email address: <a href="mailto:andrea@invalid.it">&#097;&#110;&#100;&#114;&#101;&#097;&#064;&#105;&#110;&#118;&#097;&#108;&#105;&#100;&#046;&#105;&#116;</a></p>

<p>Address: <a href="mailto:andrea@invalid.it">&#097;&#110;&#100;&#114;&#101;&#097;&#064;&#105;&#110;&#118;&#097;&#108;&#105;&#100;&#046;&#105;&#116;</a></p>
*** Output of to_latex ***
This is an email address: \href{mailto:andrea@invalid.it}{andrea\char64invalid\char46it}

Address: \href{mailto:andrea@invalid.it}{andrea\char64invalid\char46it}
*** Output of to_md ***
This is an email address:
<andrea@invalid.it>

Address: <andrea@invalid.it>
*** Output of to_s ***
This is an email address: Address:
