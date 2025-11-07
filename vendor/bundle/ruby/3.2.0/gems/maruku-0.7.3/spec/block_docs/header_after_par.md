Write a comment abouth the test here.
*** Parameters: ***
{:title=>"header"}
*** Markdown input: ***
Paragraph
### header 1 ###

Paragraph
header 2
--------

Paragraph
header 3
========

*** Output of inspect ***
md_el(:document,[
	md_par(["Paragraph"]),
	md_el(:header,["header 1"],{:level=>3},[]),
	md_par(["Paragraph"]),
	md_el(:header,["header 2"],{:level=>2},[]),
	md_par(["Paragraph"]),
	md_el(:header,["header 3"],{:level=>1},[])
],{},[])
*** Output of to_html ***
<p>Paragraph</p>

<h3 id="header_1">header 1</h3>

<p>Paragraph</p>

<h2 id="header_2">header 2</h2>

<p>Paragraph</p>

<h1 id="header_3">header 3</h1>
*** Output of to_latex ***
Paragraph

\hypertarget{header_1}{}\subsubsection*{{header 1}}\label{header_1}

Paragraph

\hypertarget{header_2}{}\subsection*{{header 2}}\label{header_2}

Paragraph

\hypertarget{header_3}{}\section*{{header 3}}\label{header_3}
*** Output of to_md ***
Paragraph

### header

Paragraph

## header

Paragraph

# header
*** Output of to_s ***
ParagraphheaderParagraphheaderParagraphheader
