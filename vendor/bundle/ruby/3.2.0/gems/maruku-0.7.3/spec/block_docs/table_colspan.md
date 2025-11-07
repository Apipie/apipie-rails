Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***

| h1        | h2  |   h3 |
|:----------|:---:|-----:|
|c1         | c2  |  c3  |
|c1         | c2         ||
|c1         ||       c2  |
|c1                      |||
{: summary="Table summary" .class1 style="color:blue" border=1 width="50%" cellspacing=2em cellpadding=4px}

{:t: scope="row"}
*** Output of inspect ***
md_el(:document,[
	md_el(:table, [
       	[md_el(:head_cell, "h1"), md_el(:head_cell, "h2"), md_el(:head_cell, "h3")],
       	[md_el(:cell, "c1"), md_el(:cell, "c2"), md_el(:cell, "c3")],
       	[md_el(:cell, "c1"), md_el(:cell, "c2", {}, [["colspan", "2"]])],
       	[md_el(:cell, "c1", {}, [["colspan", "2"]]), md_el(:cell, "c2")],
       	[md_el(:cell, "c1", {}, [["colspan", "3"]])]
       ],{:align=>[:left, :center, :right]},[["summary", "Table summary"], [:class, "class1"], ["style", "color:blue"], ["border", ""], ["width", "50%"], ["frame", "lhs"], ["rules", "cols"], ["cellspacing", "2em"], ["cellpadding", "4px"]]),
	md_el(:ald,[],{:ald=>[["scope", "row"]],:ald_id=>"t"},[])
],{},[])
*** Output of to_html ***
<table class="class1" style="color:blue" summary="Table summary" width="50%" border="1" cellspacing="2em" cellpadding="4px">
<thead><tr><th>h1</th><th>h2</th><th>h3</th></tr></thead>
<tbody><tr><td style="text-align: left;">c1</td><td style="text-align: center;">c2</td><td style="text-align: right;">c3</td></tr>
<tr><td style="text-align: left;">c1</td><td colspan="2" style="text-align: center;">c2</td></tr>
<tr><td colspan="2" style="text-align: left;">c1</td><td style="text-align: center;">c2</td></tr>
<tr><td colspan="3" style="text-align: left;">c1</td></tr></tbody></table>
*** Output of to_latex ***
\begin{tabular}{l|c|r}
h1&h2&h3\\
\hline 
c1&c2&c3\\
c1&\multicolumn {2}{|l|}{c2}\\
\multicolumn {2}{|l|}{c1}&c2\\
\multicolumn {3}{|l|}{c1}\\
\end{tabular}
