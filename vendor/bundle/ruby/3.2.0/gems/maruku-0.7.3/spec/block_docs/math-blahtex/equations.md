Write a comment here
*** Parameters: ***
require 'maruku/ext/math';{:html_math_engine => 'blahtex'}
*** Markdown input: ***

$$ x = y $$

$$ x
= y $$

$$
x = y $$

$$ x = y
$$

*** Output of inspect ***

*** Output of to_html ***
<div class="maruku-equation"><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mrow><mi>x</mi><mo lspace='0.278em' rspace='0.278em'>=</mo><mi>y</mi></mrow>
</math></div><div class="maruku-equation"><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mrow><mi>x</mi><mo lspace='0.278em' rspace='0.278em'>=</mo><mi>y</mi></mrow>
</math></div><div class="maruku-equation"><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mrow><mi>x</mi><mo lspace='0.278em' rspace='0.278em'>=</mo><mi>y</mi></mrow>
</math></div><div class="maruku-equation"><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mrow><mi>x</mi><mo lspace='0.278em' rspace='0.278em'>=</mo><mi>y</mi></mrow>
</math></div>
*** Output of to_latex ***
