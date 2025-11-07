Maruku improperly wraps list elements in paragraphs and doesn't handle nested lists right.
*** Parameters: ***
{}
*** Markdown input: ***
Here's another:

1. First
2. Second:
	* Fee
	* Fie
	* Foe
3. Third

Same thing but with paragraphs:

1. First

2. Second:
	* Fee
	* Fie
	* Foe

3. Third

*** Output of inspect ***
md_el(:document,[
 	md_par(["Here", md_entity("rsquo"), "s another:"]),
 	md_el(:ol,[
   	md_el(:li,["First"],{:want_my_paragraph=>false},[]),
   	md_el(:li,[
   	  "Second:",
   	  md_el(:ul,[
   	    md_el(:li,["Fee"],{:want_my_paragraph=>false},[]),
 	      md_el(:li,["Fie"],{:want_my_paragraph=>false},[]),
 	      md_el(:li,["Foe"],{:want_my_paragraph=>false},[])
      ],{},[])
    ],{:want_my_paragraph=>false},[]),
 	  md_el(:li,["Third"],{:want_my_paragraph=>false},[])
  ],{},[]),
 	md_par(["Same thing but with paragraphs:"]),
 	md_el(:ol,[
 	  md_el(:li,[md_par("First")],{:want_my_paragraph=>true},[]),
 	  md_el(:li,[
 	    md_par("Second:"),
 	    md_el(:ul,[
 	      md_el(:li,["Fee"],{:want_my_paragraph=>false},[]),
 	      md_el(:li,["Fie"],{:want_my_paragraph=>false},[]),
 	      md_el(:li,["Foe"],{:want_my_paragraph=>false},[])
      ],{},[])
      ],{:want_my_paragraph=>true},[]),
 	  md_el(:li,md_par("Third"),{:want_my_paragraph=>false},[])
  ],{},[])
],{},[])
*** Output of to_html ***
<p>Here&#8217;s another:</p>

<ol>
<li>First</li>
<li>Second:
<ul>
<li>Fee</li>
<li>Fie</li>
<li>Foe</li>
</ul></li>
<li>Third</li>
</ol>

<p>Same thing but with paragraphs:</p>

<ol>
<li><p>First</p></li>
<li><p>Second:</p>

<ul>
<li>Fee</li>

<li>Fie</li>

<li>Foe</li>
</ul></li>
<li><p>Third</p></li>
</ol>
*** Output of to_latex ***

*** Output of to_md ***

*** Output of to_s ***

