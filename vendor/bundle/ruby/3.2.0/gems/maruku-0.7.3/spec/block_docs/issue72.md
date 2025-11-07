https://github.com/bhollis/maruku/issues/72
*** Parameters: ***
{}
*** Markdown input: ***
1. 句子 
2. 句子
*** Output of inspect ***
md_el(:document, md_el(:ol, [
	md_el(:li, "句子", {:want_my_paragraph=>false}),
	md_el(:li, "句子", {:want_my_paragraph=>false})
]))
*** Output of to_html ***
<ol>
<li>句子</li>

<li>句子</li>
</ol>
