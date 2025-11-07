https://github.com/bhollis/maruku/issues/74
*** Parameters: ***
{}
*** Markdown input: ***
## Cool Title

<ul>
    <li>Cool Text yada yada</li>
    <li>ICool Tex 2 yada yada</li>
</ul>



<p id="icons">
    <a href="" class="stumbleupon" target="_blank">a</a>
    <a href="" class="stumbleupon" target="_blank">a</a>
    <a href="" class="stumbleupon" target="_blank">a</a>
</p>

## Recents Post
*** Output of inspect ***
md_el(:document, [
     	md_el(:header, "Cool Title", {:level=>2}),
     	md_html("<ul>\n    <li>Cool Text yada yada</li>\n    <li>ICool Tex 2 yada yada</li>\n</ul>"),
     	md_html("<p id=\"icons\">\n    <a href=\"\" class=\"stumbleupon\" target=\"_blank\">a</a>\n    <a href=\"\" class=\"stumbleupon\" target=\"_blank\">a</a>\n    <a href=\"\" class=\"stumbleupon\" target=\"_blank\">a</a>\n</p>"),
     	md_el(:header, "Recents Post", {:level=>2})
     ])
*** Output of to_html ***
<h2 id="cool_title">Cool Title</h2>
<ul>
    <li>Cool Text yada yada</li>
    <li>ICool Tex 2 yada yada</li>
</ul><p id="icons">
    <a href="" class="stumbleupon" target="_blank">a</a>
    <a href="" class="stumbleupon" target="_blank">a</a>
    <a href="" class="stumbleupon" target="_blank">a</a>
</p>
<h2 id="recents_post">Recents Post</h2>
