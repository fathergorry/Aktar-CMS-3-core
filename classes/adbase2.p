
@notes----[]

@allowed[]
tags comments populars memories announcer myrecords tabled_header1

@myrecords[arg;a2][watchin;myt;hd]
^if(def $user.id){
$watchin[^table::load[/my/config/adbase_tables.txt]]
$watchin[^watchin.select(^watchin.cls.pos[u]>=0)]
^use[modinfo.p]
$newad[^modinfo::create[ad-base.p]]
^connect[$scs]{
^watchin.menu{
$myt[^table::sql{SELECT ^sr_out_name[$watchin.adt], path, id, moderated FROM ^dtp[$watchin.adt] WHERE ^if(def ^cando[editor base-editor]){moderated != 'yes'}{editby = '$MAIN:userid'}   }]
	<h3>$watchin.name</h3>
	^myt.menu{
	<a href="^myt.path.match[action=show][ig]{action=edit}"><img src="/login/img/edit.gif" border=0></a>
	<a href="$myt.path">^untaint{$myt.name} $myt.id ^if($myt.moderated ne yes){<img src="/login/img/eye.gif" title="Не модерировано" border=0>}</a>}[<br>]
	^newad.focus[table;$watchin.adt]
	<p><a href="^newad.returnpath[]?action=edit&id=new">^newad.returnval[newtitle]</a>
}}$document.pagetitle[Панель управления]

}{<p>Панель уравления доступна только для зарегистрированных пользователей<p>}
@announcer[tab][an]
^try{
^use[datawork.p]
^connect[$scs]{$an[^table::sql{SELECT ^sr_out_name[$tab], path 
FROM ^dtp[$tab] WHERE moderated != 'no' ORDER BY lastmodified DESC LIMIT 3}]}
^an.menu{<a href="$an.path" class="sided">$an.name<img src="/my/templates/mak/more.gif" class="morei"></a><p>}
}{$exception.handled(0)неверный источник данных}
@memories[q]

^if($adtabs is table){;$adtabs[^table::load[/my/config/adbase_tables.txt]]}
^use[adb_search.p] 
^adtabs.menu{ 
	^mem2[$q;$adtabs.adt] 
}
^if(def $membase){$document.pagetitle[Результаты поиска '$q'] $membase}
@mem2[qqq;tab][rest]

$rest[^adbsearch:defquery[$qqq;$tab]]
^if(def $rest){$membase[$membase 
<h3>$adtabs.name: ^rest.count[]</h3>
<ul>^rest.menu{
<li><a href="^app_path[$rest.path;$adtabs.adt]">$rest.name</a> <br>
}</ul> ]
}

@app_path[path;table][locals]

$result[$path]
^if($adtabs is table){;$adtabs[^table::load[/my/config/adbase_tables.txt]]}
^if(^adtabs.locate[adt;$table] && def $adtabs.uri){
	^if(^path.pos[?]>=0){
		$tmp[^path.split[?;lh]]
		^if(^tmp.0.length[] <= 1){$result[$adtabs.uri?$tmp.1]}{$result[$path]}
	}{$result[$path]}
}{$result[$path]}


@populars[pp][frm;is;page]
^cache[/cache/populars](5200){
^connect[$scs]{$frm[^table::sql{
SELECT COUNT(fid) AS score, fid FROM ^dtp[forum] 
WHERE $before[^date::now(-^pp.int(-21))] mydate >= '^before.sql-string[]'
GROUP BY fid ORDER BY score DESC LIMIT 6
}]}

^frm.menu{
	^if(^frm.fid.int(0)){$is[news]}{
		^if(^frm.fid.left(1) eq "/"){$is[structure]}{
			$tmp[^frm.fid.trim[end;1234567890]] $tmp(^tmp.length[]) $sTable[^frm.fid.left($tmp)]
			^if(^frm.fid.length[] != $tmp && -f "/my/dbs/${sTable}.txt"){$is[adtab]}{$is[]} 
		}
	}
^if(def $is){^connect[$scs]{$page[^table::sql{
	SELECT path, 
	^switch[$is]{
		^case[structure]{menutitle AS name}
		^case[news]{title AS name}
		^case[adtab]{
			^sr_out_name[$sTable]
		}
	}, '$frm.score' AS score
	FROM ^dtp[^switch[$is]{^case[adtab]{$sTable}^case[DEFAULT]{$is}}] WHERE 
	^switch[$is]{
		^case[news]{id = '$frm.fid'}
		^case[structure]{path = '$frm.fid'}
		^case[adtab]{id = '^frm.fid.mid($tmp;99)'}
	}
	AND ^switch[$is]{
		^case[adtab]{moderated = 'yes'}
		^case[structure]{visiblity != 'no'}
		^case[news]{ 1 }
	}
}]}}
^if($pages is table){;$pages[^table::create{path	name	score}]}
^if($page is table){^pages.join[$page]}
}
^pages.menu{<a href="$pages.path" class="sided">$pages.name 
($pages.score)<img src="/my/templates/mak/more.gif" class="morei"/></a>}[<br>]
}

@tags[data;sm][kuc]
$a[^table::sql{SELECT DISTINCT $data.column AS name, COUNT($data.column) AS score
FROM ^dtp[$data.table] WHERE moderated = 'yes' GROUP BY $data.column ORDER BY score DESC LIMIT 125}]
^if(def $data.div){
	$kuc[^hash::create[]]
	^a.menu{
		$tmp[^a.name.split[$data.div;v]]
		^tmp.menu{
			$tmp2[^tmp.piece.trim[]]
			^try{^kuc.$tmp2.inc($a.score)}{$exception.handled(1)$kuc.$tmp2(1)}
		}
	}
$a[^table::create{name	score
^kuc.foreach[k;v]{$k	$v
}}]
}

^tagcloud[$a;$data.url?filter=field&field=$data.column&value;, 
]

#delete after ADBase switched to akbd
@sr_out[tab;anc]
$anc[^db_fld2showinlist[$tab]] CONCAT(
^switch[$tab]{
	^case[person]{$anc.1, ' ', $anc.2, ', ', $anc.3}
	^case[news]{DATE_FORMAT(postdate, '%d.%m.%Y' ), ', ', title}
	^case[adsite]{$anc.1, ' \(',$anc.2,'\)'}
	^case[abc]{$anc.1}
	^case[hot]{'<big><b>', resource, '</b></big><br> ', name, ', до ', ^sql_rumonth[dto]}
#	^case[hot]{'С ', ^sql_rumonth[dfrom], ' по ', ^sql_rumonth[dto], ' ', DATE_FORMAT(dto, '%Y'), 'г, ', $anc.1}
	^case[tender]{$anc.1, ' \(', $anc.2, '\), действует до ',  ^sql_rumonth[dto]}
	^case[DEFAULT]{$anc.1, ', ', $anc.2, ', ', $anc.3}
} )

@sr_out_name[tab][anc]
$anc[^db_fld2showinlist[$tab]]
^try{^use[/my/config/akbd_selector.cfg]^akbd_selector[$tab;$anc]}{
^if($exception.type eq "file.missing"){^blad[]
	CONCAT(^switch[$tab]{
	^case[news]{DATE_FORMAT(postdate, '%d.%m.%Y' ), ', ', title}
	^case[DEFAULT]{$anc.1, ', ', $anc.2, ', ', $anc.3}
	}) AS name

}
}
@adb_tabselorder[tab]
^switch[$tab]{
	^case[DEFAULT]{lastmodified DESC}
}

@sql_rumonth[field]
DATE_FORMAT($field, '%d'), ' ', 
CASE DATE_FORMAT($field, '%m') 
WHEN 12 THEN 'Декабря' WHEN 11 THEN 'Ноября' 
WHEN 10 THEN 'Октября' WHEN 09 THEN 'Сентября' 
WHEN 08 THEN 'Августа' WHEN 07 THEN 'Июля' 
WHEN 06 THEN 'Июня' WHEN 05 THEN 'Мая' WHEN 04 THEN 'Апреля' 
WHEN 03 THEN 'Марта' WHEN 02 THEN 'Февраля' WHEN 01 THEN 'Января'
ELSE 'месяца' END

#######################################
#COMMON HANDLERS#######################
#######################################
@adb_edited_by[by][h]
^if(^by.int(0)){$h($by)}{$h(0)}
^if($form:id eq new && !def ^cando[editor users base-editor]){$h($MAIN:user.id)}
^if(!def ^cando[editor users base-editor] && $h != ^MAIN:userid.int(-1)){
	^die[Вам нельзя редактировать эту запись]
	$datawork:CLASS.data_error(1) 
	$MAIN:hideForm[<!-- -->]
}{^if(^form:reassign_editor.int(0)){$h($form:reassign_editor)}}
$result($h)

@adb_compurl[url][res]
$res[$MAIN:uri?action=show&id=]
^if(!^form:id.int(0)){$MAIN:update_adb_url[$res]}
$result[${res}^form:id.int(0)]

@adb_ismoderated[yes]
$result[^if($yes ne yes){no;yes}]
^if($form:action eq edit && !def ^cando[editor users base-editor unmoderated]){$result[no]}{}

@currentdate_sql[d][dd]
$dd[^date::now[]]
$result[^dd.sql-string[]]

@savefile[file0;exts;prname;path]
$result[]
^if($file0 is file && ^form:id.int(0)){
	$exts[^s2h[$exts]]$r[^file:justext[$file0.name]]
	^if(def $exts.$r){
		$fprname[${prname}_^form:id.int(0).$r]
		^file0.save[binary;$path/$fprname]
		$result[$path/$fprname]
	}{^die[Неверный формат файла "$prname". Допускаются ^exts.foreach[k;v]{$k}[, ]]}
}{^if(!^form:id.int(0)){^die[Необходимо еще раз загрузить файл]}}
