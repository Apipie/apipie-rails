Escaped content in raw HTML. See https://github.com/bhollis/maruku/issues/85
*** Parameters: ***
{}
*** Markdown input: ***
<pre><span class="cp">#include &lt;foo&gt; &#x201c;</span></pre>

Foo <span><code>#include &lt;foo&gt; &#x201c;</code></span> bar

Foo <span class="cp">#include &lt;foo&gt; &#x201c;</span> bar
*** Output of inspect ***
md_el(:document, [md_html("<pre><span class=\"cp\">#include &lt;foo&gt; &#x201c;</span></pre>"),
        md_par([
        "Foo ",
        md_html("<span><code>#include &lt;foo&gt; &#x201c;</code></span>"),
        " bar"]),
        md_par([
        "Foo ",
        md_html("<span class=\"cp\">#include &lt;foo&gt; &#x201c;</span>"),
        " bar"])
])
*** Output of to_html ***
<pre><span class="cp">#include &lt;foo&gt; “</span></pre>
<p>Foo <span><code>#include &lt;foo&gt; “</code></span> bar</p>

<p>Foo <span class="cp">#include &lt;foo&gt; “</span> bar</p>