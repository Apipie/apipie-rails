require File.dirname(__FILE__) + '/spec_helper'
require 'rspec'
require 'maruku'

EXPECTATIONS = Maruku.new.instance_eval do
  [
    ["",       [],         'Empty string gives empty list'],
    ["a",      ["a"],      'Easy char'],
    [" a",     ["a"],      'First space in the paragraph is ignored'],
    ["a\n \n", ["a"],      'Last spaces in the paragraphs are ignored'],
    [' ',      [],      'One char => nothing'],
    ['  ',     [],      'Two chars => nothing'],
    ['a  b',   ['a b'],    'Spaces are compressed'],
    ['a  b',   ['a b'],    'Newlines are spaces'],
    ["a\nb",   ['a b'],    'Newlines are spaces'],
    ["a\n b",  ['a b'],    'Compress newlines 1'],
    ["a \nb",  ['a b'],    'Compress newlines 2'],
    [" \nb",   ['b'],      'Compress newlines 3'],
    ["\nb",    ['b'],      'Compress newlines 4'],
    ["b\n",    ['b'],     'Compress newlines 5'],
    ["\n",     [],      'Compress newlines 6'],
    ["\n\n\n", [],      'Compress newlines 7'],

    # Code blocks
    ["`" ,   :raise,  'Unclosed single ticks'],
    ["``" ,  [md_entity("ldquo")],  'Empty code block'],
    ["`a`" ,     [md_code('a')],    'Simple inline code'],
    ["`` ` ``" ,    [md_code('`')],   ],
    ["`` \\` ``" ,    [md_code('\\`')],   ],
    ["``a``" ,   [md_code('a')],    ],
    ["`` a ``" ,   [md_code('a')],    ],

    # Newlines
    ["a  \n", ['a',md_el(:linebreak)], 'Two spaces give br.'],
    ["a \n",  ['a'], 'Newlines 2'],
    ["  \n",  [md_el(:linebreak)], 'Newlines 3'],
    ["  \n  \n",  [md_el(:linebreak),md_el(:linebreak)],'Newlines 4'],
    ["  \na  \n",  [md_el(:linebreak),'a',md_el(:linebreak)],'Newlines 5'],

    # Inline HTML
    ["a < b", ['a < b'], '< can be on itself'],
    ["<hr>",  [md_html('<hr />')], 'HR will be sanitized'],
    ["<hr/>", [md_html('<hr />')], 'Closed tag is ok'],
    ["<hr  />", [md_html('<hr />')], 'Closed tag is ok 2'],
    ["<hr/>a", [md_html('<hr />'),'a'], 'Closed tag is ok 2'],
    ["<em></em>a", [md_html('<em></em>'),'a'], 'Inline HTML 1'],
    ["<em>e</em>a", [md_html('<em>e</em>'),'a'], 'Inline HTML 2'],
    ["a<em>e</em>b", ['a',md_html('<em>e</em>'),'b'], 'Inline HTML 3'],
    ["<em>e</em>a<em>f</em>",
      [md_html('<em>e</em>'),'a',md_html('<em>f</em>')],
      'Inline HTML 4'],
    ["<em>e</em><em>f</em>a",
      [md_html('<em>e</em>'),md_html('<em>f</em>'),'a'],
      'Inline HTML 5'],

    ["<img src='a' />", [md_html("<img src='a' />")], 'Attributes'],
    ["<img src='a'/>"],

    # emphasis
    ["**", :raise, 'Unclosed double **'],
    ["\\*", ['*'], 'Escaping of *'],
    ["a *b* ", ['a ', md_em('b')], 'Emphasis 1'],
    ["a *b*", ['a ', md_em('b')], 'Emphasis 2'],
    ["a * b", ['a * b'], 'Emphasis 3'],
    ["a * b*", :raise, 'Unclosed emphasis'],
    # same with underscore
    ["__", :raise, 'Unclosed double __'],
    ["\\_", ['_'], 'Escaping of _'],
    ["a _b_ ", ['a ', md_em('b')], 'Emphasis 4'],
    ["a _b_", ['a ', md_em('b')], 'Emphasis 5'],
    ["a _ b", ['a _ b'], 'Emphasis 6'],
    ["a _ b_", :raise, 'Unclosed emphasis'],
    ["_b_", [md_em('b')], 'Emphasis 7'],
    ["_b_ _c_", [md_em('b'),' ',md_em('c')], 'Emphasis 8'],
    ["_b__c_", [md_em('b'),md_em('c')], 'Emphasis 9', true], # PENDING
    # underscores in word
    ["mod_ruby", ['mod_ruby'], 'Word with underscore'],
    # strong
    ["**a*", :raise, 'Unclosed double ** 2'],
    ["\\**a*", ['*', md_em('a')], 'Escaping of *'],
    ["a **b** ", ['a ', md_strong('b')], 'Emphasis 1'],
    ["a **b**", ['a ', md_strong('b')], 'Emphasis 2'],
    ["a ** b", ['a ** b'], 'Emphasis 3'],
    ["a ** b**", :raise, 'Unclosed emphasis'],
    ["**b****c**", [md_strong('b'),md_strong('c')], 'Emphasis 9'],
    ["*italic***bold***italic*", [md_em('italic'), md_strong('bold'), md_em('italic')], 'Bold inbetween italics'], # Issue #103
    # strong (with underscore)
    ["__a_", :raise, 'Unclosed double __ 2'],

    ["a __b__ ", ['a ', md_strong('b')], 'Emphasis 1'],
    ["a __b__", ['a ', md_strong('b')], 'Emphasis 2'],
    ["a __ b", ['a __ b'], 'Emphasis 3'],
    ["a __ b__", :raise, 'Unclosed emphasis'],
    ["__b____c__", [md_strong('b'),md_strong('c')], 'Emphasis 9'],
    # extra strong
    ["***a**", :raise, 'Unclosed triple *** '],
    ["\\***a**", ['*', md_strong('a')], 'Escaping of *'],
    ["a ***b*** ", ['a ', md_emstrong('b')], 'Strong elements'],
    ["a ***b***", ['a ', md_emstrong('b')]],
    ["a *** b", ['a *** b']],
    ["a ** * b", ['a ** * b']],
    ["***b******c***", [md_emstrong('b'),md_emstrong('c')]],
    ["a *** b***", :raise, 'Unclosed emphasis'],
    # same with underscores
    ["___a__", :raise, 'Unclosed triple *** '],
    ["a ___b___ ", ['a ', md_emstrong('b')], 'Strong elements'],
    ["a ___b___", ['a ', md_emstrong('b')]],
    ["a ___ b", ['a ___ b']],
    ["a __ _ b", ['a __ _ b']],
    ["___b______c___", [md_emstrong('b'),md_emstrong('c')]],
    ["a ___ b___", :raise, 'Unclosed emphasis'],
    # mixing is bad
    ["*a_", :raise, 'Mixing is bad'],
    ["_a*", :raise],
    ["**a__", :raise],
    ["__a**", :raise],
    ["___a***", :raise],
    ["***a___", :raise],
    ["*This is in italic, and this is **bold**.*", [md_em(["This is in italic, and this is ", md_strong("bold"), "."])], 'Issue #23'],

    # links of the form [text][ref]
    ["\\[a]",  ["[a]"], 'Escaping 1'],
    ["\\[a\\]", ["[a]"], 'Escaping 2'],
    # This is valid in the new Markdown version
    ["[a]",   [ md_link(["a"],nil)], 'Empty link'],
    ["[a][]", [ md_link(["a"],'')] ],
    ["[a][]b",   [ md_link(["a"],''),'b'], 'Empty link'],
    ["[a\\]][]", [ md_link(["a]"],'')], 'Escape inside link (throw ?] away)'],

    ["[a",  :raise,   'Link not closed'],
    ["[a][",  :raise,   'Ref not closed'],

    # links of the form [text](url)
    ["\\[a](b)",  ["[a](b)"], 'Links'],
    ["[a](url)c",  [md_im_link(['a'],'url'),'c'], 'url'],
    ["[a]( url )c" ],
    ["[a] (	url )c" ],
    ["[a] (	url)c" ],

    ["[a](ur:/l/ 'Title')",  [md_im_link(['a'],'ur:/l/','Title')],
      'url and title'],
    ["[a] (	ur:/l/ \"Title\")" ],
    ["[a] (	ur:/l/ \"Title\")" ],
    ["[a]( ur:/l/ Title)", :raise, "Must quote title" ],

    ["[a](url 'Tit\\\"l\\\\e')", [md_im_link(['a'],'url','Tit"l\\e')],
      'url and title escaped'],
    ["[a] (	url \"Tit\\\"l\\\\e\")" ],
    ["[a] (	url	\"Tit\\\"l\\\\e\"  )" ],
    ['[a] (	url	"Tit\\"l\\\\e"  )' ],
    ["[a]()", [md_im_link(['a'],'')], 'No URL is OK'],

    ["[a](\"Title\")", :raise, "No url specified" ],
    ["[a](url \"Title)", :raise, "Unclosed quotes" ],
    ["[a](url \"Title\\\")", :raise],
    ["[a](url \"Title\" ", :raise],

    ["[a](url \'Title\")", :raise, "Mixing is bad" ],
    ["[a](url \"Title\')"],

    ["[a](/url)", [md_im_link(['a'],'/url')], 'Funny chars in url'],
    ["[a](#url)", [md_im_link(['a'],'#url')]],
    ["[a](</script?foo=1&bar=2>)", [md_im_link(['a'],'/script?foo=1&bar=2')]],

    # Links to URLs that contain closing parentheses. #128
    ['[a](url())', [md_im_link(['a'],'url()')], 'Link with parentheses 1', true], # PENDING
    ['[a](url\(\))', [md_im_link(['a'],'url()')], 'Link with parentheses 2', true], # PENDING
    ['[a](url()foo)', [md_im_link(['a'],'url()foo')], 'Link with parentheses 3', true], # PENDING
    ['[a](url(foo))', [md_im_link(['a'],'url(foo)')], 'Link with parentheses 4', true], # PENDING

    # Images
    ["\\![a](url)",  ['!', md_im_link(['a'],'url') ], 'Escaping images'],

    ["![a](url)",  [md_im_image(['a'],'url')], 'Image no title'],
    ["![a]( url )" ],
    ["![a] (	url )" ],
    ["![a] (	url)" ],

    ["![a](url 'ti\"tle')",  [md_im_image(['a'],'url','ti"tle')], 'Image with title'],
    ['![a]( url "ti\\"tle")' ],

    ["![a](url", :raise, 'Invalid images'],
    ["![a( url )" ],
    ["![a] ('url )" ],

    ["![a][imref]",  [md_image(['a'],'imref')], 'Image with ref'],
    ["![a][ imref]",  [md_image(['a'],' imref')], 'Image with ref'],
    ["![a][ imref ]",  [md_image(['a'],' imref ' )], 'Image with ref'],
    ["![a][\timref\t]",  [md_image(['a'],"\timref\t")], 'Image with ref'],


    ['<http://example.com/?foo=1&bar=2>',
      [md_url('http://example.com/?foo=1&bar=2')], 'Immediate link'],
    ['<https://example.com/?foo=1&bar=2>',
      [md_url('https://example.com/?foo=1&bar=2')], 'Immediate link https'],
    ['a<http://example.com/?foo=1&bar=2>b',
      ['a',md_url('http://example.com/?foo=1&bar=2'),'b']  ],
    ['<andrea@censi.org>',
      [md_email('andrea@censi.org')], 'Email address'],
    ['<mailto:andrea@censi.org>'],
    ["Developmen <http://rubyforge.org/projects/maruku/>",
      ["Developmen ", md_url("http://rubyforge.org/projects/maruku/")]],
    ["a<!-- -->b", ['a',md_html('<!-- -->'),'b'],
      'HTML Comment'],

    ["a<!--", :raise, 'Bad HTML Comment'],
    ["a<!-- ", :raise, 'Bad HTML Comment'],

    ["<?xml <?!--!`3  ?>", [md_xml_instr('xml','<?!--!`3')], 'XML processing instruction'],
    ["<? <?!--!`3  ?>", [md_xml_instr('','<?!--!`3')] ],

    ["<? ", :raise, 'Bad Server directive'],

    ["a <b", :raise, 'Bad HTML 1'],
    ["<b",   :raise, 'Bad HTML 2'],
    ["<b!",  :raise, 'Bad HTML 3'],
    ['`<div>`, `<table>`, `<pre>`, `<p>`',
      [md_code('<div>'),', ',md_code('<table>'),', ',
        md_code('<pre>'),', ',md_code('<p>')],
      'Multiple HTML tags'],

    ["&andrea", ["&andrea"], 'Parsing of entities'],
    # no escaping is allowed
    ["\\&andrea;", ["\\", md_entity("andrea")]],
    ["l&andrea;", ["l", md_entity('andrea')] ],
    ["&&andrea;", ["&", md_entity('andrea')] ],
    ["&123;;&amp;",[md_entity('123'),';',md_entity('amp')]],

    ["a\nThe [syntax page] [s] provides",
      ['a The ', md_link(['syntax page'],'s'), ' provides'], 'Regression'],

    ['![a](url "ti"tle")', [md_im_image(['a'],'url','ti"tle')],
      "Image with quotes"],
    ['![a](url \'ti"tle\')' ],

    ['[bar](/url/ "Title with "quotes" inside")',
      [md_im_link(["bar"],'/url/', 'Title with "quotes" inside')],
      "Link with quotes"],
  ]
end

EXPECTATIONS.each_cons(2) {|l, r| r[1] ||= l[1]}

describe "The Maruku span parser" do
  before(:each) do
    @doc = Maruku.new
    @doc.attributes[:on_error] = :raise
  end

  EXPECTATIONS.each do |md, res, comment, pend|
    if res == :raise
      it "should raise an error (#{comment}) for \"#{md}\"" do
        pending if pend
        lambda {@doc.parse_span(md)}.should raise_error(Maruku::Exception)
      end
    else
      it "should parse \"#{md}\" as #{res.inspect}" do
        pending if pend
        @doc.parse_span(md).should == res
      end
    end
  end
end
