
@CLASS
html
@auto[]
$breaks_after_tags[^table::create{from	to
</font>	
</span>	
</o:p>	
<o:p>	
</FONT>	
</SPAN>	
<td>^taint[^#0A^#0A]	<td>^taint[^#0A]
</td>^taint[^#0A^#0A]	</td>^taint[^#0A]
</p>^taint[^#0A^#0A]	</p>^taint[^#0A]
<br>^taint[^#0A^#0A]	<br>^taint[^#0A]
^taint[^#0A^#0A]<ul>	^taint[^#0A]<ul>
</ul>^taint[^#0A^#0A]	</ul>^taint[^#0A]
^taint[^#0A^#0A]<li>	^taint[^#0A]<li>
</p>	</p>^taint[^#0A]
<br>	<br>^taint[^#0A]
<ul>	^taint[^#0A]<ul>
</ul>	</ul>^taint[^#0A]
<li>	^taint[^#0A]<li>
</td>	</td>^taint[^#0A]
<td>	^taint[^#0A]<td>}]


@ClearWordFormatting[text][txt]
$txt[^text.match[<(span|font|\?xml)[^^>]*>][ig]{ }]
$txt[^txt.match[<(p|ul|li|div|b|br)[^^>]*>][ig]{<$match.1>}]
$txt[^txt.replace[$breaks_after_tags]]
$result[$txt]

@ClearTableFormatting[text][txt]
$txt[^text.match[<(span|font|\?xml)[^^>]*>][ig]{ }]
$txt[^txt.match[<(td|tr|tbody|table)[^^>]*>][ig]{<$match.1>}]
$txt[^txt.replace[$breaks_after_tags]]
$result[$txt]

@SetBreaks[txt]
$result[^if(def $txt){^txt.replace[$breaks_after_tags]}]

@SetLinks[text]
$result[^if(def $text){^text.match[(?<![="])((?:http://|ftp://)(?:[:\w~%{}./?=&@,#-]+))(?<![.:])(?!"<)][gi]{<a href="$match.1">$match.1</a>}}]