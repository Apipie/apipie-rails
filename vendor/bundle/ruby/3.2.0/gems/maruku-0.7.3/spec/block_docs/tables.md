PHP Markdown Extra table syntax
*** Parameters: ***
{} # params 
*** Markdown input: ***

Col1    | Very very long head | Very very long head|
------- |:-------------------:|-------------------:|
cell    | center-align        | right-align        |
another | cell                | here               |

| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

*** Output of inspect ***
md_el(:document, [
	md_el(:table, [
	[md_el(:head_cell, "Col1"), md_el(:head_cell, "Very very long head"), md_el(:head_cell, "Very very long head")],
	[md_el(:cell, "cell"), md_el(:cell, "center-align"), md_el(:cell, "right-align")],
	[md_el(:cell, "another"), md_el(:cell, "cell"), md_el(:cell, "here")]
], {:align=>[:left, :center, :right]}),
	md_el(:table, [
	[md_el(:head_cell, "First Header"), md_el(:head_cell, "Second Header")],
	[md_el(:cell, "Content Cell"), md_el(:cell, "Content Cell")],
	[md_el(:cell, "Content Cell"), md_el(:cell, "Content Cell")]
], {:align=>[:left, :left]}),
	md_el(:table, [
	[md_el(:head_cell, "First Header"), md_el(:head_cell, "Second Header")],
	[md_el(:cell, "Content Cell"), md_el(:cell, "Content Cell")],
	[md_el(:cell, "Content Cell"), md_el(:cell, "Content Cell")]
], {:align=>[:left, :left]})
])
*** Output of to_html ***
<table><thead><tr><th>Col1</th><th>Very very long head</th><th>Very very long head</th></tr></thead><tbody><tr><td style="text-align: left;">cell</td><td style="text-align: center;">center-align</td><td style="text-align: right;">right-align</td></tr>
<tr><td style="text-align: left;">another</td><td style="text-align: center;">cell</td><td style="text-align: right;">here</td></tr>
</tbody></table><table><thead><tr><th>First Header</th><th>Second Header</th></tr></thead><tbody><tr><td style="text-align: left;">Content Cell</td><td style="text-align: left;">Content Cell</td></tr>
<tr><td style="text-align: left;">Content Cell</td><td style="text-align: left;">Content Cell</td></tr>
</tbody></table><table><thead><tr><th>First Header</th><th>Second Header</th></tr></thead><tbody><tr><td style="text-align: left;">Content Cell</td><td style="text-align: left;">Content Cell</td></tr>
<tr><td style="text-align: left;">Content Cell</td><td style="text-align: left;">Content Cell</td></tr>
</tbody></table>

