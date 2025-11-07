Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***

Col1 | Very very long head | Very very long head|
-----|:-------------------:|-------------------:|
cell | center-align  ABB   | right-align        |

*[ABB]: An Abbreviation
*** Output of inspect ***
md_el(:document, [
     md_el(:table, [
	  [md_el(:head_cell, "Col1"), md_el(:head_cell, "Very very long head"), md_el(:head_cell, "Very very long head")],
	  [md_el(:cell, "cell"), md_el(:cell, ["center-align ", md_el(:abbr, "ABB", {:title=>"An Abbreviation"})]), md_el(:cell, "right-align")]
     ], {:align=>[:left, :center, :right]}),
	 md_el(:abbr_def, [], {:abbr=>"ABB", :text=>"An Abbreviation"})
])
*** Output of to_html ***
<table><thead><tr><th>Col1</th><th>Very very long head</th><th>Very very long head</th></tr></thead><tbody><tr><td style="text-align: left;">cell</td><td style="text-align: center;">center-align <abbr title="An Abbreviation">ABB</abbr></td><td style="text-align: right;">right-align</td></tr>
</tbody></table>
*** Output of to_latex ***
\begin{tabular}{l|c|r}
Col1&Very very long head&Very very long head\\
\hline 
cell&center-align ABB&right-align\\
\end{tabular}
