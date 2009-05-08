@auto[]


@etc[]

@visualeditor[]
^if(def ^cando[editor $epermission]){
^use[/login/auto.p]
  ^if($env:REQUEST_METHOD eq POST){
    ^connect[$scs]{^save_visual[]}
  }{
    ^try{^use[/plugins/visualeditor.p]^current_visualeditor[$document.content;vcontent]}{^blad[]^htmlarea[$document.content]}
  }
}{
^die[268]
}

@VECP[text;doptions][result]
^taint[as-is][
	^if(!def $doptions.exec){
		^if(def $doptions.unbrul){
			^source.replace[^unbrul[]]
		}{
			$source
		}
	}{
		^content_foredit[$source]
	}
]


@save_visual[][content;saveto;sect_key;c]
$content[^if(!def $doptions.exec){$form:vcontent}{^content_prepare[$form:vcontent]}]
$c[^content.split[<STYLE;lh]]$content[^taint[sql][$c.0]]
^if($form:editcontent eq $uri){$saveto[$uri]}{
  ^if(def ^cando[editor] && $form:editcontent eq "/"){$saveto[/]}
}
^if(def $saveto){
$sect_key[^string:sql{SELECT sect_key FROM ^dtp[structure] WHERE path = '$saveto'}[$.default{}]]
^if(def $sect_key){

$asfileext[^s2h[html shtml; ]]
$thisext[^file:justext[^default[$document.asfile;i.go]]]
^if(!def $asfileext.$thisext){$smsg[^lang[414]]
^void:sql{UPDATE ^dtp[sections] SET content = '$content', this_settings='^document.this_settings.match[unbrul][ig]{}' WHERE sect_key = '$sect_key'}
}{$smsg[Saved to file]
$f2[@main[]
^^makepage[$uri]]
$f3[@content[]]
$rfiledata[$f2
$f3
^taint[as-is][^if(def $content){$content}{ }]]
^rfiledata.save[$document.asfile]
}
^redirect[$saveto^rn[?]&msg=^taint[uri;$smsg]]

}{^die[469]}
}
@htmlarea[source;fieldName]
<style type="text/css"><!--
.headline { font-family: arial black, arial; font-size: 28px; letter-spacing: -1px; }
.headline2{ font-family: verdana, arial; font-size: 12px; }
.subhead  { font-family: arial, arial; font-size: 18px; font-weight: bold; font-style: italic; }
.backtotop     { font-family: arial, arial; font-size: xx-small;  }
.code  { background-color: #EEEEEE; font-family: Courier New; font-size: x-small;
  margin: 5px 0px 5px 0px; padding: 5px;
  border: black 1px dotted;
}
--></style>
<script language="Javascript1.2"><!-- // load htmlarea
_editor_url = "/plugins/htmlarea/";                     // URL to htmlarea files
var win_ie_ver = parseFloat(navigator.appVersion.split("MSIE")[1]);
if (navigator.userAgent.indexOf('Mac')        >= 0) { win_ie_ver = 0; }
if (navigator.userAgent.indexOf('Windows CE') >= 0) { win_ie_ver = 0; }
if (navigator.userAgent.indexOf('Opera')      >= 0) { win_ie_ver = 0; }
if (win_ie_ver >= 5.5) {
  document.write('<scr' + 'ipt src="' +_editor_url+ 'editor.js"');
  document.write(' language="Javascript1.2"></scr' + 'ipt>');
} else { document.write('<scr'+'ipt>function editor_generate() { return false; }</scr'+'ipt>'+'Use IE 5.5 or higher'); }
// --></script>

<form action="^if($uri eq "/" || !def $uri){$menu.0.uri/}{$uri/}" method="post"^if($css_positioning){style="width:400px"}>
^if(def $uri){<input type=hidden name="editcontent" value="$uri">}
<div align=right><input type=submit style="border-width: 1px^; font-size: xx-small" value="Сохранить"></div>
<textarea name="^default[$fieldName;vcontent]" ^if($css_positioning){}{style="width:100%"} rows=33>^VECP[$source;$doptions]</textarea>
<script language="javascript1.2">
editor_generate('^default[$fieldName;vcontent]');
</script>
<input type=submit value="Сохранить">
<input type=hidden name=rn value=^rn[?]></form>

@mshtml[source;fname;exec;width]
<style type="text/css"><!--
.headline { font-family: arial black, arial; font-size: 28px; letter-spacing: -1px; }
.headline2{ font-family: verdana, arial; font-size: 12px; }
.subhead  { font-family: arial, arial; font-size: 18px; font-weight: bold; font-style: italic; }
.backtotop     { font-family: arial, arial; font-size: xx-small;  }
.code  { background-color: #EEEEEE; font-family: Courier New; font-size: x-small;
  margin: 5px 0px 5px 0px; padding: 5px;
  border: black 1px dotted;
}
--></style>
<script language="Javascript1.2"><!-- // load htmlarea
_editor_url = "/plugins/htmlarea/";                     // URL to htmlarea files
var win_ie_ver = parseFloat(navigator.appVersion.split("MSIE")[1]);
if (navigator.userAgent.indexOf('Mac')        >= 0) { win_ie_ver = 0; }
if (navigator.userAgent.indexOf('Windows CE') >= 0) { win_ie_ver = 0; }
if (navigator.userAgent.indexOf('Opera')      >= 0) { win_ie_ver = 0; }
if (win_ie_ver >= 5.5) {
  document.write('<scr' + 'ipt src="' +_editor_url+ 'editor.js"');
  document.write(' language="Javascript1.2"></scr' + 'ipt>');
} else { document.write('<scr'+'ipt>function editor_generate() { return false; }</scr'+'ipt>'+'Use IE 5.5 or higher'); }
// --></script>

<textarea name="$fname" style="width:$width" rows=33>^taint[as-is][^if(!def $exec){$source}{^try{^content_foredit[$source]}{$exception.handled(1)^die[Ошибка в данных, содержание удалено]}}]</textarea>
<script language="javascript1.2">
editor_generate('$fname');
</script>
