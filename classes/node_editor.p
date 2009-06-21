@version[]
2009-04-22	Чек-поле в конце формы
2009-02-27	Настройки модуля v.2
2008-04-10	Попытка ресайза картинки узла

@save_picture[][pcname]
$pic_ext[^s2h[gif jpg jpeg png]]
^if(def $form:picture){^if(def $pic_ext.[^file:justext[$form:picture.name]]){
	$pcname[^saveable[$form:picture.name]]
	^if(-f "/my/img/node_pics/$pcname"){^die[$form:picture.name ^lang[411]]}
	^form:picture.save[binary;/my/img/node_pics/$pcname]
	^updpict1[$pcname]
	^if(^globals.nodepicsizex.int(0)){^imgresize[/my/img/node_pics/$pcname;$globals.nodepicsizex]}
}{^die[$form:picture.name  ^lang[412]]}}{
	^if(def $form:delpic){ ^updpict1[]
	^try{^file:delete[/my/img/node_pics/$document.picture]}{$exception.handled(1)}}
}
@updpict1[arg]
^void:sql{UPDATE ^dtp[sections] SET picture = '$arg' WHERE sect_key = '$document.sect_key'} $document.picture[$arg]
@save_node[][t;isext]
$structuref[^table::load[/my/dbs/structure.txt]]
$sectionsf[^table::load[/my/dbs/sections.txt]]
$stf[^hash::create[]]$sef[^hash::create[]] 
#fields not updated by default or updated via special handler
$noupdate[^s2h[sect_key parent path level created keywords description title menutitle pagetitle content picture]]
^structuref.menu{^if(!$noupdate.[$structuref.column]){$stf.[$structuref.column][$form:[$structuref.column]]}}
^sectionsf.menu{^if(!$noupdate.[$sectionsf.column]){$sef.[$sectionsf.column][$form:[$sectionsf.column]]}}
#filling up these fields...
$stf.modified[^now.sql-string[]]
$stf.add_block[^for[i](0;99){^if(def $form:placeholder$i){^noser_div[,,;ph]$i==$form:placeholder$i}}]
$sef.keywords[^headquotes[$form:keywords]] $sef.title[^headquotes[$form:title]] $sef.description[^headquotes[$form:description]]
$stf.menutitle[^headquotes[$form:menutitle]] $sef.pagetitle[^headquotes[$form:pagetitle]]

$t[$form:tables.doptions]
^if(def $t){$sef.this_settings[^t.menu{$t.field}[ ]] $doptions[^s2h[$sef.this_settings]]}{$doptions[]}
#^saveprglist[]
^memory:compact[]
$sef.content[^taint[sql][^if(!def $doptions.exec){$form:content}{^content_prepare[$form:content]}]]
^if(def $errors){^sef.delete[content] ^sef.delete[this_settings]}{
$isext[^s2h[html shtml; ]]
^if(def $form:asfile){^if(-f "/my/file_content$form:asfile" && def $isext.[^file:justext[$form:asfile]]){^use[asfile.p]^asfile[]}{
^die[^lang[413;Не удалось сохранить как файл]]^sef.delete[asfile]}}
}
^if(def $form:module){$sef.module_settings[^mod_set_compact[^file:justname[$form:module]]]}
$stf.rpermission[ ^stf.rpermission.trim[both; ] ]$stf.epermission[ ^stf.epermission.trim[both; ] ]

^try{^file:delete[/cache/www/^md5[$form:p]]}{$exception.handled(1)}

^updn[structure;$stf]
^updn[sections;$sef]
^msg[414;Документ обновлен.]
^environment[$form:p]
@updn[table;hash]
^void:sql{UPDATE ^dtp[$table] SET ^hash.foreach[k;v]{$k = '$v'}[, ] WHERE sect_key = '$document.sect_key'}
@saveprglist[]
$prglist[^table::sql{SELECT s.module, s.path, se.module_settings FROM ^dtp[structure] s LEFT JOIN ^dtp[sections] se ON s.sect_key = se.sect_key WHERE s.module != ''}]
^prglist.save[/my/deriv/modules.txt;$.encloser[^#03]]
@edit_node[]
^if(def $form:movemsg){^msg[416;move ok]}
^if($env:REQUEST_METHOD eq "POST"){^if(def ^cando[editor $epermission]){
	^if(def $form:save_node){^save_node[]}{^save_picture[]}
}{^die[269;Нельзя редактировать узел]}}
$tabindex(0)
^if($document.status eq 404){^die[Cannot edit unexisting node]}
<form action="/login/update.htm?p=$form:p" name="post" method="post" style="display:inline">
<br>


<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td valign="top">
<TABLE border=0 width=700 cellPadding=1 cellSpacing=0>

<TR>
<TD class=dsc width="300"><span title="^lang[138]" class=hnd>^lang[105]</span> </TD>
<TD class=dsc>
<table border=0 cellspacing=0 cellpadding=0 class=lfield width=100%><tr><td>
<input name="menutitle" value="$document.menutitle" type="text" size="35" ^tabindex[]>
</td><td align=right class=dsc>
<span title="^lang[129]" class=hnd>^lang[129]</span>
^select_language[language;$document.language]
</td></tr></table>
</TD>
</TR>
<TR>
<TD class=dsc><span title="^lang[139]" class=hnd>^lang[106]:<span> </TD>
<TD class=dsc>
<table border=0 cellspacing=0 cellpadding=0 class=lfield width=100%><tr><td>
<input name="sect_order" type="text" value="$document.sect_order" size="3" ^tabindex[]>
</td><td align=right class=dsc>
<span title="^lang[144]" class=hnd>^lang[110]:</span>
<input type=radio name=visiblity ^tabindex[] value="yes"^if(!def $document.visiblity || $document.visiblity eq yes){ checked}>^lang[145]

   <input type=radio name=visiblity tabindex="$tabindex" value="no"^if($document.visiblity eq no){ checked}>^lang[146]
   <input type=radio name=visiblity tabindex="$tabindex" value="nomenu"^if($document.visiblity eq nomenu){ checked}>^lang[147]
</td></tr></table>
</TD>
</TR>
<TR>
<TD class=dsc>^lang[140] </TD>
<TD>
<input name="pagetitle" type="text" size="84" class="lfield" value="$document.pagetitle" ^tabindex[]>
</TD>
</TR>
<TR>
<TD class=dsc><span title="^lang[141]" class=hnd>^lang[108]:</span></TD>
<TD>
<input name="title" type="text" size="84" class="lfield" value="$document.title" ^tabindex[]>
</TD>
</TR>
<TR>
<TD class=dsc><span title="^lang[142]" class=hnd>^lang[109]:</span> </TD>
<TD>
<input name="keywords" type="text" size="84" class="lfield" value="$document.keywords" ^tabindex[]>
</TD>
</TR>
<TR>
<TD class=dsc><span title="^lang[143]" class=hnd>^lang[111]:</span> </TD>
<TD>
<input name="description" class="lfield" ^tabindex[] value="$document.description" size="84">
</TD>
</TR>
<TR>
<TD class=dsc>^lang[102]: </TD>
<TD>
<table border=0 width=100% cellspacing=0 cellpadding=0 class=lfield><tr><td>
<select name="module" ^tabindex[] onChange="this.form.submit()">
<option value="">^lang[151;не использовать]</option>
$macros[^file:list[/modules;\.p^$]]
^macros.join[^file:list[/login/modules;\.p^$]]
 ^macros.sort{^pseudoname:find[$macros.name]}
^macros.menu{<option value="$macros.name"^if($document.module eq $macros.name){ selected}>^pseudoname:find[$macros.name]</options>}
</select>
</td><td align=right>
^if(def $document.module && def ^cando[editor]){<a href="mgs.htm?module=^file:justname[$document.module]">^lang[472] "^pseudoname:find[$document.module]"</a>}
</td></tr></table>
^if(def $document.module && (-f "/modules/${document.module}" || -f "/login/modules/${document.module}")){
<tr><td colspan=2 bgcolor="#FFF2E9">
^mod_set_display[^file:justname[$document.module];$document.module_settings]
^try{$topstr[^^^file:justname[$document.module]_info[^^expand[$document.module_settings]]]<br>
<span style="background-color: #FFFFFF">^process{$topstr}</span>}{$exception.handled(1)^die[$exception.comment in @info]}
</td></tr>
}


</TD>
</TR>
<TR>
<TD valign=top><span title="^lang[149]" class=hnd>^lang[150]</span><br>

</td><td><table border=0 cellspacing=0 cellpadding=0 width="100%"><tr>
<td>[<a href="$document.path?^rn[]&editcontent=on">^lang[294]</a>]</td><td align="right">
<input name=send title="^lang[152;Сохранить все настройки]" type=submit value="^lang[152]" ^tabindex[]>
</td></tr></table>
</td></tr>
</TABLE>

</tr></table>


^if(def ^cando[editor $epermission] && def $form:cp){
	^use[htmlworks.p]
	^switch[$form:cp]{
		^case[word]{$document.content[^html:ClearWordFormatting[$document.content]]}
		^case[tables]{$document.content[^html:ClearTableFormatting[$document.content]]}
		^case[breaks]{$document.content[^html:SetBreaks[$document.content]]}
	}
}
^use[htedco.p]
<style>.htmledit{width:100%}</style>
^htedco[content;^if(def $errors){^taint[as-is][$form:content]}{^taint[as-is][^if(!def $doptions.exec){$document.content}{^content_foredit[$document.content]}]};^if(^document.content.length[] > 600){22}{11};65]
<div align="right"><nobr><small> <a href="update.htm?p=$form:p&cp=word^rn[&]">Clean MSWord text</a> <a href="update.htm?p=$form:p&cp=tables^rn[&]">Clean tables</a>
 <a href="update.htm?p=$form:p&cp=breaks^rn[&]">Set breaks</a> </small></nobr></div>
<table border=0><tr><td valign=top>
^if(!def $femodules){$femodules[^hash::create[]]}
^placeblock.foreach[k;v]{$femodules.$v(1)}

^if($document.module ne "ad-base.p" && !def $femodules.[nomacro.p]){
<input type=checkbox name=doptions value=exec id=allowmacro ^if(^must_have_macro[]){checked}> ^lang[417;allow macros]
}<br>
^fbool[doptions;unbrul;^if(def $doptions.unbrul){unbrul}] ^lang[418;autoformat]
</td>$f_ext[^s2h[p cfg w; ]]



<td valign=top>^if($femodules is hash){^lang[419;Редактировать макросы]: ^femodules.foreach[k;v]{^if(def $f_ext.[^file:justext[$k]]){<a href="blocks.htm?block=$k">$k</a> }}}</td></tr></table>


<div align="center"><br>
 <input name=send type=submit value=^lang[152] ^tabindex[]>
 </div>
<br>
^if(^hasrig[simple]){<div style="width:1px^; height:1px^; overflow:hidden">}
<table width="100%" border="1" cellpadding="2" cellspacing="0" bordercolor="#1486A2">
<tr>
<td bordercolor="#F0F9FB">

<B>^lang[172]</B> <b><a href="/login/help/branch_help.html" target=_blank>?</a></b>

<br>

^if(def ^cando[$.editor(1)]){<span title="^lang[154]" class=hnd>^lang[153;Права на редактирование ветви (через пробел)]:</span>
<input type="text" name="epermission" value="$document.epermission" ^tabindex[]>
}{<input type="hidden" name="epermission" value="$document.epermission">}
<nobr> ^lang[420;Права на чтение ветви]:
 <input type="text" name="rpermission" value="$document.rpermission"^tabindex[]></nobr>
<br><nobr><span title="^lang[155]" class=hnd>^lang[156]:</span>
<select name="design" ^tabindex[]>
$templates[^file:list[/my/templates;\.htm^$]]
<option value="">^lang[157;Наследовать свыше]</option>
^templates.menu{<option value="$templates.name"^if($document.design eq $templates.name){ selected}>$templates.name</option>}
</select></nobr>
$this_blocks0[^expand[$document.add_block]] $this_blocks[^this_blocks0.hash[param]]
$placeholder_check(1)
^placehld_check[]
^if(def $phcount){<p><a href="blocks.htm">^lang[395]</a> ^lang[473] ${design}:
<table border=0>
^phcount.foreach[k;v]{<tr><td align=right>$phoptions.$k ($k):</td><td> ^select_blocks[$k;$v]</td></tr>}
</table>
}
</td></tr>
</table><div align="center">
 <input name=send type=submit value=^lang[152] ^tabindex[]>
 </div>
 <br><br><br>
# $myset[^usersettings::create[]] Включить: ^myset.edit[$.nodeoptions[Настройки ветви]$.seoptions[Настройки поиска] $.tcontrols[html-редактор] $.blocksettings[Установки модулей в дизайне]]
# Чё это за хуйня вобще?
<br>
<nobr>^lang[474] <input type=text name=asfile value="$document.asfile"></nobr><br>
^switch[^form:p.trim[end;/]]{^case[/;/search;/login]{}^case[DEFAULT]{
<input type=checkbox name="delete_move_node" value="$form:p">^lang[160;Удалить или переместить этот раздел и подразделы]
}}
<input type=hidden name="save_node" value="^math:uid64[]">
 </form>
^if(^hasrig[simple]){</div>}
 <hr>
 <form action="/login/update.htm?p=$form:p" enctype="multipart/form-data" method=post>
 ^lang[475]<br>
 
<input type="file" name="picture" >
 ^if(def $document.picture){<input type=checkbox name=delpic value=1>^lang[93;удалить]}
 <br>
 <input type=submit value="^lang[476]">
 </form>
 ^if(def $document.picture){<img src="/my/img/node_pics/$document.picture">}
@must_have_macro[][locals]
$result(0)
^if(def $doptions.exec){$result(1)}
$brkopen(^document.content.pos[^[] >= 0)
$brkclose(^document.content.pos[^]] >= 0)
^if($brkopen && $brkclose){$result(1)}
^if(!$brkopen || !$brkclose){$result(0)}
^if($document.nomacro){$result(0)}
@placehld_check[][f]
^if(-f "/my/templates/$design"){
^use[/my/templates/$design]
 ^design[1;1;1]
}
$result[]
@select_blocks[id;bl]
^if(!def $allblocks){$allblocks[^file:list[/my/blocks;\.(p|cfg|w)^$]]^allblocks.sort{$allblocks.name}}
<select name="placeholder$id">
<option value="">^if((def $placeblock.$id) && ($placeblock.$id ne "$this_blocks.$id.value")){^lang[421;Наследовать] ^pseudoname:find[$placeblock.$id]}{^lang[422;Не определен]}</option>
<option value="clear"^if($this_blocks.$id.value eq "clear"){ selected>^lang[423;Наследование в этом месте отменяется]}{>^lang[424;Отменить наследование] $placeblock.$id}</option>
^allblocks.menu{^if(^allblocks.line[] < 50){<option value="$allblocks.name"^if($this_blocks.$id.value eq "$allblocks.name"){ selected}>^pseudoname:find[$allblocks.name]</option>}}

</select>
@mod_set_display[mod;modset][tab;topstr]
^if($modset is table){}{$modset[^expand[$modset]]}
^use[^modpath[${mod}.p]]
$topstr[^^${mod}_settings^[^]]
$tab[^process{$topstr}]
$modval[^bmodval[$document.module;^hash::create[]]]

<table cellspacing=0 cellpadding=0>
^tab.menu{ 
	<tr title="$tab.param==" ^if(^math:frac(^tab.offset[]/2)){bgcolor="#FFFFFF"}>
	<td class=dsc width="200">$tab.descr</td>
	<td>^mod_set_switch[$tab.fields;^if(^modset.locate[param;$tab.param]){$modset.value};$mod]</td></tr>
}</table>

@mvpaint[modval;param;value]
^if(^mvcheck[$modval;$param;$value]){^if(def $form:p){style="background-color:#C9C9C9"} 
title="Будет ^taint[html]["^default[$modval.value;^lang[478]]"] ^lang[477]"}
@mod_set_switch[tab;modset;mod][tm;rv]
^switch[$tab.type]{
  ^case[string;translit;option;num]{
		<input ^tabindex[] type=text ^if($tab.type eq num){size=4}{class=modsetstr size=50} 
	 	name="${mod}_$tab.param" ^mvpaint[$modval.[$tab.param];$tab.param;$tab.value]
		 value="^default[$modset;$tab.default]" > 
  }
  ^case[bool]{
  	<input ^tabindex[] type=checkbox name="${mod}_$tab.param" 
	  ^mvpaint[$modval.[$tab.param];$tab.param;$tab.value]
	  value="$tab.default"^if(def $modset){ checked}>
	}
  ^case[radio;select]{
    $tm[^expand[$tab.default]]
    $rv[^default[$modset;$tm.param]]
    <select tabindex="$tabindex" name="${mod}_$tab.param" ^mvpaint[$modval.[$tab.param];$tab.param;$tab.value] >
    ^tm.menu{<option value="$tm.param"^if($tm.param eq $rv){ selected}>$tm.value</option> }
    </select>
}
}

@mod_set_compact[mod][tab;topstr;t;tm;rv;tp;mtp]
^use[^modpath[${mod}.p]]
$topstr[^^${mod}_settings^[^]]
$tab[^process{$topstr}] $tabset[^table::create{param	value}]
^tab.menu{$tp[$tab.param] $mtp[${mod}_$tp]^switch[$tab.type]{
  ^case[translit]{^tabset.append{$tp	^saveable[$form:$mtp]}}
  ^case[string;option]{^tabset.append{$tp	$form:$mtp}}
  ^case[bool]{^tabset.append{$tp	^if(def $form:$mtp){$tab.default}}}
  ^case[radio]{
    $tb[^expand[$tab.default]]^tabset.append{$tp	$tmp(^tb.locate[param;$form:$mtp])$tb.param}
  }
  ^case[num]{^tabset.append{$tp	^form:$mtp.double($tab.default)}}
}}
$tabset1[^table::create{param	value}]
^tabset.menu{^if(def $tabset.value){^tabset1.append{$tabset.param	$tabset.value}}}
$result[^compact[$tabset1]]
@CLASS
aktar_macros

@foredit[data][rep]
$data[^data.match[&(nbsp|quot|gt|lt|amp)][ig]{&amp^^^;$match.1}]
$rep[^table::create{from	to
^^exec_module[	^^mod_foredit^[
^^wiki[	^^mod_foredit^[
}] $femodules[^hash::create[]]
$result[^process{^data.replace[$rep]}]
