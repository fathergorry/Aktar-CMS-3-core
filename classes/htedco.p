@auto[]
$taRulesRep[^table::create{from	to
<textarea	&lt^;textarea
<TEXTAREA	&lt^;TEXTAREA}]

@htedco[id;value;rows;cols;add]
<script language="javascript">
textareaEdit = '^taint[js][$id]'^;
</script>
<script language="javascript" src="/login/scripts/htmleditor.js"></script>
^taControls[$add]
<textarea class="htmledit" name="$id" id="^default[$id;message]" rows="^default[$rows;14]" cols="^default[$cols;68]"
 onselect="sc(this);" onclick="sc(this);" onkeyup="sc(this);">^value.replace[$taRulesRep]</textarea>


@taPrepare[data]
$result[]

@taControls[add;remove]
$add[^table::create{in	out	value
^untaint{$add}}]
^add.menu{
	<input type="button" value="^taint[html][^default[$add.value;$add.in $add.out]]"
	onClick="^if(def $add.out){surnd('$add.in', '$add.out', 0)}{instxt('$add.in')}" />
}
<input type="button" accesskey="b" value="B" style="font-weight:bold; width: 18px" onClick="surnd('<b>', '</b>', 0)" />
<input type="button" accesskey="i" value="i" style="font-style:italic; width: 20px" onClick="surnd('<i>', '</i>', 0)" />
<input type="button" accesskey="w" value="URL" style="text-decoration: underline; width: 40px" onClick="surnd('<a href=\'\'>', '</a>', -2)" />
^if($document.module ne "ad-base.p"){
<input type="button" accesskey="a" value="@" style="width: 40px" onClick="surnd('\[email\^;', '\]', -1)^;^if(def $form:p){document.getElementById('allowmacro').checked='checked'}" />
}
<input type="button" accesskey="l" value="<UL>" style="width: 40px" onClick="surnd('<ul>', '</ul>', 0)" />
<input type="button" accesskey="o" value="<OL>" style="width: 40px" onClick="surnd('<ol>', '</ol>', 0)" />
<input type="button" accesskey="w" value="« »" style="width: 30px" onClick="surnd('«', '»', 0)" />
<a href="javascript:instxt('<li>')">&lt^;li&gt^;</a> <a href="javascript:instxt('\n <p>\n')">&lt^;p&gt^;</a><a href="javascript:instxt('<br>\n')">&lt^;br&gt^;</a>
<select name="hs">
      <option value="">^lang[31]</option>
      <option value="1">h1</option>
      <option value="2">h2</option>
      <option value="3">h3</option>
      <option value="4">h4</option>
      <option value="5">h5</option>
</select><input type=button onClick="surnd('<h' + this.form.hs.options[this.form.hs.selectedIndex].value + '>', '</h' + this.form.hs.options[this.form.hs.selectedIndex].value + '>', 0)" value="&gt^;">

^connect[$scs]{$myfiles[^table::sql{SELECT * FROM ^dtp[useroptions] WHERE id = '$user.id' AND param = 'pic'}]}
^myfiles.sort{^if($myfiles.param eq file){zz}$myfiles.comment}[asc]
<select class="files1" name="files1" onChange="instxt('<img src=\'' + this.form.files1.options[this.form.files1.selectedIndex].value + '\' border=0 align=\'\' />')">
<option value="">^lang[24]</option>
^myfiles.menu{
<option value="$myfiles.value">$myfiles.comment</option>
}
</select> <a href="/login/files.htm" target="_blank" class="loadfiles">load files</a><br>
