Make sure extended attributes get escaped when generating HTML: https://github.com/bhollis/maruku/issues/114
*** Parameters: ***
{} # params
*** Markdown input: ***
*foo*{: style='ball & chain'}

*foo*{: style='ball\008 chain'}

*foo*{: style='ball\" badAttribute=\"chain'}
*** Output of inspect ***
md_el(:document, [
  md_par(md_em("foo", [["style", "ball & chain"]])),
  md_par(md_em("foo", [["style", "ball\\008 chain"]])),
  md_par(md_em("foo", [["style", "ball\" badAttribute=\"chain"]]))
])
*** Output of to_html ***
<p><em style="ball &amp; chain">foo</em>
</p>
<p><em style="ball\008 chain">foo</em>
</p>
<p><em style="ball&quot; badAttribute=&quot;chain">foo</em>
</p>
