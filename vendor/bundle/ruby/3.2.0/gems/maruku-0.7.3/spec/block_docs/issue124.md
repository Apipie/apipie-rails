Handle blocks of inline HTML without a newline without complaining. https://github.com/bhollis/maruku/issues/124
*** Parameters: ***
{:on_error => :raise}
*** Markdown input: ***
What follows uses ruby
<ruby>
    <rb>東</rb><rp>(</rp><rt>トウ</rt><rp>)</rp>
    <rb>京</rb><rp>(</rp><rt>キョウ</rt><rp>)</rp>
</ruby>.
*** Output of inspect ***

*** Output of to_html ***
<p>What follows uses ruby <ruby>
    <rb>東</rb><rp>(</rp><rt>トウ</rt><rp>)</rp>
    <rb>京</rb><rp>(</rp><rt>キョウ</rt><rp>)</rp>
</ruby>.</p>
