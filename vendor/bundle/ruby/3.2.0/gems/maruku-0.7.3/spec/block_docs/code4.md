Codes which look like lists
*** Parameters: ***
{}
*** Markdown input: ***

This is code (4 spaces):

    * Code
      * Code (again)

This is also code

    * Code
	* Code (again)

This is code (1 tab):

	* Code
		* Code (again)


*** Output of inspect ***
md_el(:document,[
	md_par(["This is code (4 spaces):"]),
	md_el(:code,[],{:raw_code=>"* Code
  * Code (again)", :lang=>nil},[]),
	md_par(["This is also code"]),
	md_el(:code,[],{:raw_code=>"* Code
* Code (again)", :lang=>nil},[]),
	md_par(["This is code (1 tab):"]),
	md_el(:code,[],{:raw_code=>"* Code
	* Code (again)", :lang=>nil},[])
],{},[])
*** Output of to_html ***
<p>This is code (4 spaces):</p>

<pre><code>* Code
  * Code (again)</code></pre>

<p>This is also code</p>

<pre><code>* Code
* Code (again)</code></pre>

<p>This is code (1 tab):</p>

<pre><code>* Code
	* Code (again)</code></pre>
*** Output of to_latex ***
This is code (4 spaces):

\begin{verbatim}* Code
  * Code (again)\end{verbatim}
This is also code

\begin{verbatim}* Code
* Code (again)\end{verbatim}
This is code (1 tab):

\begin{verbatim}* Code
	* Code (again)\end{verbatim}
*** Output of to_md ***
This is code (4 spaces):

     * Code
       * Code (again)

This is also code

     * Code
     * Code (again)

This is code (1 tab):

     * Code
         * Code (again)
*** Output of to_s ***
This is code (4 spaces):This is also codeThis is code (1 tab):

