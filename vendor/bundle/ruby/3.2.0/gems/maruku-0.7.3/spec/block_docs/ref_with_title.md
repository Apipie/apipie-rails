Comment
*** Parameters: ***
{}
*** Markdown input: ***
[bar][1].

[1]: /url/ "Title"
*** Output of inspect ***
md_el(:document,[
        md_par([md_link(["bar"],"1"), "."]),
        md_ref_def("1", "/url/", {:title=>"Title"})
],{},[])
*** Output of to_html ***
<p><a href="/url/" title="Title">bar</a>.</p>
*** Output of to_latex ***
\href{/url/}{bar}.
*** Output of to_md ***
[bar][1].

[1]: /url/ "Title"
*** Output of to_s ***
bar.
