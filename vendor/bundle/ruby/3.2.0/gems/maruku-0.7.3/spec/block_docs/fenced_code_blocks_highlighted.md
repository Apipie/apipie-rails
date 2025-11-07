Fenced code blocks
*** Parameters: ***
{ :fenced_code_blocks => true, :html_use_syntax => true }
*** Markdown input: ***
```ruby
john = Twitter::Client.new(
  :oauth_token => "John's access token",
  :oauth_token_secret => "John's access secret"
)
```
*** Output of inspect ***

*** Output of to_html ***
<pre class="ruby"><code class="ruby"><span class="ident">john</span> <span class="punct">=</span> <span class="constant">Twitter</span><span class="punct">::</span><span class="constant">Client</span><span class="punct">.</span><span class="ident">new</span><span class="punct">(</span>
  <span class="symbol">:oauth_token</span> <span class="punct">=&gt;</span> <span class="punct">"</span><span class="string">John's access token</span><span class="punct">",</span>
  <span class="symbol">:oauth_token_secret</span> <span class="punct">=&gt;</span> <span class="punct">"</span><span class="string">John's access secret</span><span class="punct">"</span>
<span class="punct">)</span></code></pre>
