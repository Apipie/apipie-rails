This should threat the last as a literal asterisk.
*** Parameters: ***
{:on_error=>:warning}
*** Markdown input: ***
 Hello: ! \! \` \{ \} \[ \] \( \) \# \. \! * \* *


Ora, *emphasis*, **bold**, * <- due asterischi-> * , un underscore-> _ , _emphasis_,
 incre*dible*e!

This is ``Code with a special: -> ` <- ``(after)

`Start ` of paragraph

End of `paragraph `
*** Output of inspect ***
md_el(:document,[
	md_par(["Hello: ! ! ` { } [ ] ( ) # . ! * * *"]),
	md_par([
		"Ora, ",
		md_em(["emphasis"]),
		", ",
		md_strong(["bold"]),
		", * <- due asterischi-> * , un underscore-> _ , ",
		md_em(["emphasis"]),
		", incre",
		md_em(["dible"]),
		"e!"
	]),
	md_par(["This is ", md_code("Code with a special: -> ` <-"), "(after)"]),
	md_par([md_code("Start "), " of paragraph"]),
	md_par(["End of ", md_code("paragraph ")])
],{},[])
*** Output of to_html ***
<p>Hello: ! ! ` { } [ ] ( ) # . ! * * *</p>

<p>Ora, <em>emphasis</em>, <strong>bold</strong>, * &lt;- due asterischi-&gt; * , un underscore-&gt; _ , <em>emphasis</em>, incre<em>dible</em>e!</p>

<p>This is <code>Code with a special: -&gt; ` &lt;-</code>(after)</p>

<p><code>Start </code> of paragraph</p>

<p>End of <code>paragraph </code></p>
*** Output of to_latex ***
Hello: ! ! ` \{ \} [ ] ( ) \# . ! * * *

Ora, \emph{emphasis}, \textbf{bold}, * {\tt \symbol{60}}- due asterischi-{\tt \symbol{62}} * , un underscore-{\tt \symbol{62}} \_ , \emph{emphasis}, incre\emph{dible}e!

This is {\colorbox[rgb]{1.00,0.93,1.00}{\tt Code\char32with\char32a\char32special\char58\char32\char45\char62\char32\char96\char32\char60\char45}}(after)

{\colorbox[rgb]{1.00,0.93,1.00}{\tt Start\char32}} of paragraph

End of {\colorbox[rgb]{1.00,0.93,1.00}{\tt paragraph\char32}}
*** Output of to_md ***
Hello: ! \! \` \{ \} \[ \] \( \) \# \. \! * \* *


Ora, *emphasis*, **bold**, * <- due
asterischi-> * , un underscore-> _ ,
*emphasis*, incre*dible*e!

This is ``Code with a special: -> ` <- ``(after)

`Start ` of paragraph

End of `paragraph `
*** Output of to_s ***
Hello: ! ! ` { } [ ] ( ) # . ! * * *Ora, emphasis, bold, * <- due asterischi-> * , un underscore-> _ , emphasis, incrediblee!This is (after) of paragraphEnd of
