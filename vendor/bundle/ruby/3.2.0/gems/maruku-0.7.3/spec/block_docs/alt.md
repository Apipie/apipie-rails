Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
 ![bar](/foo.jpg)


*** Output of inspect ***
md_el(:document,[md_par([md_im_image(["bar"], "/foo.jpg", nil)])],{},[])
*** Output of to_html ***
<p><img src="/foo.jpg" alt="bar" /></p>
*** Output of to_latex ***

*** Output of to_md ***
![bar](/foo.jpg)
*** Output of to_s ***
bar
