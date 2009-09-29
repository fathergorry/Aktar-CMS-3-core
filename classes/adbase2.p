
@auto[]
#^MAIN:allowed_modules.add[^s2h[myrecords memories announcer tags comments populars]]
#$allowed_modules[^s2h[myrecords memories announcer tags comments populars]]
#^die[^h2s:h2s[$allowed_modules]]
@myrecords[arg;a2][watchin;myt;hd]
^if(def $user.id){
$watchin[^table::load[/my/config/adbase_tables.txt]]
$watchin[^watchin.select(^watchin.cls.pos[u]>=0)]

^use[modinfo.p]
$newad[^modinfo::create[akbd.p]]
^watchin.menu{
^connect[$scs]{$myt[^table::sql{
	SELECT ^sr_out_name[$watchin.adt], path, id, moderated 
	FROM ^dtp[$watchin.adt]  
	WHERE ^if(def ^cando[editor base-editor]){moderated != 'yes'}{editby = '$MAIN:userid'}   
}]}
<h3>$watchin.name</h3>
	^myt.menu{
$serep[^table::create{a	b
action=show	action=edit
id=0	id=$myt.id}]
	<a href="^myt.path.replace[$serep]"><img src="/login/img/edit.gif" border=0></a>
	<a href="^myt.path.match[id=0][ig]{id=$myt.id}">^untaint{$myt.name} $myt.id 
	^if($myt.moderated ne yes){<img src="/login/img/eye.gif" title="Не модерировано" border=0>}
	</a>
	}[<br>]
^newad.focus[table;$watchin.adt]
<p><a href="^newad.returnpath[]?action=edit&id=new">^newad.returnval[newtitle]</a>
}$document.pagetitle[Панель управления]

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
^adtabs.menu{^if(^adtabs.cls.pos[s]>=0){ 
	^mem2[$q;$adtabs.adt] 
}}
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


@tPopulars[days;limit][frm;is;page;pages]
^connect[$scs]{$frm[^table::sql{
SELECT COUNT(fid) AS score, fid FROM ^dtp[forum] 
WHERE $before[^date::now(-^days.int(-21))] mydate >= '^before.sql-string[]'
AND fid ^if($limit ne forum){NOT} LIKE 'f_%'
GROUP BY fid ORDER BY score DESC LIMIT ^limit.int(6)
}]}
$pages[^table::create{path	name	score	fid}]
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
	}, '$frm.score' AS score, '$frm.fid' AS fid
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
^if($page is table){^pages.join[$page]}
}
$result[$pages]


@tags[data;sm][kuc]
$a[^table::sql{SELECT DISTINCT $data.column AS name, COUNT($data.column) AS score
FROM ^dtp[$data.table] WHERE moderated = 'yes' GROUP BY $data.column ORDER BY score DESC LIMIT 125}]
^if(def $data.div){
	$kuc[^hash::create[]]
	^a.menu{
		$tmp[^a.name.split[$data.div;v]]
		^tmp.menu{
			$tmp2[^tmp.piece.trim[]]
			^if(^tmp2.length[]>3){
				^try{^kuc.$tmp2.inc($a.score)}{$exception.handled(1)$kuc.$tmp2(1)}
			}
		}
	}
$a[^table::create{name	score
^kuc.foreach[k;v]{$k	$v
}}]
}

^if(!def $data.div){
^tagcloud[$a;$data.url?filter=field&field=$data.column&value;, 
]
}{
^tagcloud[$a;/search?q;, 
]
}

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


#vt - predefined values as 1-column 'ad' table
@edit_set[val;vt] #Edit set
^if(def $val){
$val[^expand[$val]]
$val[^val.menu{$.[$val.param][1]}]
}{$val[^hash::create[]]}
^vt.menu{<input type=checkbox name="_fieldname_" value="$vt.ad" ^if(def $val.[$vt.ad]){checked}>
$vt.ad<br>}

@commasep2list[cs]
$result[^cs.replace[^table::create{a	b
,,	,}]]

