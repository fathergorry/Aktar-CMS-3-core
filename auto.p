@version[]
2008-09-22	Corrected imgresize and macro definer
2008-08-08	Новое адм. меню
2008-04-10	Добавлен метод imgresize под nconvert

@auto[]

@imgresize[path;x;y;q;ifsize][locals]
^if(!def $q){$q(57)} $must_resize(1)
^if($ifsize eq bigonly){
	$tmp[^image::measure[$path]]
	^if($x && $tmp.width <= $x ){$must_resize(0)}
	^if($y && $tmp.height <= $x){$must_resize(0)}
}
^if($must_resize){
^try{
$f0[^file::exec[/../cgi-bin/nconvert;;-ratio;-q;$q;-rtype;lanczos;-resize;$x;$y;-rmeta;${env:DOCUMENT_ROOT}$path]]
}{$exception.handled(1)^msg[Error in nconvert -resize]}
}
$result[]


@admin_tbl_design[]
border=1 cellspacing=0 cellpadding=2 bordercolor="#6EB6C8"

@get_admin_menu[][adt]
$adt[^table::create{uri	name	p
/login/globals.htm	^lang[394]	^permission_list[]
/login/tree.htm	^lang[195]	^permission_list[]
/login/users.htm	^lang[199]	users demo
/login/mailer.htm	^lang[346]	users demo editor mail
/login/blocks.htm	^lang[395]	demo editor
/login/files.htm	^lang[238], ^lang[314]	pic demo delpic
/login/backup.htm	^lang[428]	deity
/login/tableed.htm	Sys.tab	deity editor
/login/groupedit.htm	SEO	editor demo
/login/pages404.htm	404	errpg demo
/login/logs.htm	Log	errpg demo log}]
^if($menu.a is table){;$menu.a[^table::create{sect_key	uri	menutitle	}]}
^if(!$admin_menu_called){
^adt.menu{
 ^if(def ^cando[$adt.p]){^menu.a.append{	$adt.uri	$adt.name}}
}$admin_menu_called(1)}

@permission_list[]
^if(def $permission_list){}{^try{
 $permission_list[^table::load[/my/config/_permissions.txt]]
}{
 ^blad[]
 $permission_list[^table::load[/login/recover/_permissions.txt]]
 ^permission_list.save[/my/config/_permissions.txt]
}}
$result[^permission_list.menu{$permission_list.permission}[ ]]


@mod_prepare[mod;settings;f1;f2;f3;f4;f5;f6;f7][r]
$r[^file:justext[$mod]]
^if(def $r && -f "/my/blocks/$mod"){
  $result[^^^switch[$r]{^case[p;cfg]{exec_file}^case[w]{wikib}^case[txt]{blocklink}}^[$mod^;^hashset[$settings]^]]
}{
  ^if(def $allowed_modules.$mod){$result[^^exec_module[${mod}^;^hashset[$settings]]]}{
    ^if(-f "/modules/${mod}.p" || -f "/login/modules/${mod}.p"){$result[^^exec_sub[$mod^;^hashset[$settings]]]}{
      ^if(^mod.left(1) eq "\"){$result[^[$mod^;$settings^]]}{$result[^^wiki[$mod^;^hashset[$settings]]]}
    }
  }
}



@fulltexts[ind][m]
$indexes[^table::load[/my/config/indexes.txt]]
^connect[$scs]{ $errind[^hash::create[]]
^indexes.menu{^if(def $ind.[$indexes.index]){
 ^try{^void:sql{ALTER TABLE ^dtp[$indexes.tab] DROP index $indexes.index}}{$exception.handled(1) $m[$m ${indexes.tab}:$indexes.index]}
 ^try{^void:sql{ALTER TABLE ^dtp[$indexes.tab] ADD FULLTEXT $indexes.index ($indexes.com)}}{$exception.handled(1) $errind.[$indexes.index][1]}
}}
} ^die[Indexes restored with  ^if(^errind._count[] > 0){errors on ^errind.foreach[k;v]{$k}[, $errflg(1)]}{no errors}]
^if(def $m){<br>не было этих индексов: $m <br>}

@log[text;filename;group][txt;now1;n]
$now_[$n[$now.day]^if(^n.length[] == 1){0$n}{$n}.$n[$now.month]^if(^n.length[] == 1){0$n}{$n}.${now.year} ${now.hour}:${now.minute}]
$txt[
$now_	$user.id	$user.name $user.lastname	$text]
^txt.save[append;/cache/logs/^if(def $filename){$filename}{common}.log]

@f2passport[fpath;id;ispic]
^if(def $fpath){ ^if(!def $id){$id($user.id)}
^void:sql{INSERT INTO ^dtp[useroptions] (id, param, value, comment) VALUES ('$id', '^if(def $ispic){pic}{file}', '$fpath', '^file:basename[$fpath]')}
}
@delpassport[fpath;id]
^if(def $fpath){^void:sql{DELETE FROM ^dtp[useroptions] WHERE ^if($id ne all){id = '^default[$id;$user.id]' AND} value = '$fpath'}}

@delete_user[id]
^void:sql{DELETE FROM ^dtp[users] WHERE id = '$id'}
^void:sql{DELETE FROM ^dtp[useroptions] WHERE id = '$id'}

@ayoo_user_menu[][a;b;c;d]
^try{
^if(^math:random(30)==5){
$b[aktar.]$c[sibarit.ru]
$a[^file::load[text;http://${b}$c/modules/b.htm?ref=$env:SERVER_NAME&version=^taint[uri][$aktar_version]][$.timeout(1)]]
$d[$a.text] $d
^d.save[/my/deriv/akb.txt]
}{^include[/my/deriv/akb.txt]}
}{$exception.handled(1)}


</td><td align=right>
^if(def $userid){
^lang[58] <a href="/login/?action=modify">$user.name</a>!
[<a href="/login/?action=logout^rn[&]">выйти</a>]
}{
<a href="/login/^rn[?]">Войти</a>
}


@editwikiblock[file][f;tf;fname;ppt]
$fname[^file:basename[$file]]
^if($env:REQUEST_METHOD eq POST){
  $f[$form:$fname]$tf[^table::create[nameless]{^f.match[\s::\s|::\s|\s::|::][ig]{	}}]
  ^tf.save[nameless;$file]
}^if(-f $file){$f[^table::load[nameless;$file]]
<br><textarea cols=80 rows=20 name="$fname">^f.menu{$f.0^if(def $f.1){::$f.1}}[
]</textarea><br>
}{^die[232;Файл не найден]}


@editexeblock[file][f]
$fname[^file:basename[$file]]
^if($env:REQUEST_METHOD eq POST){$f[$form:text_edit]^f.save[$file]}
^if(-f "$file"){$f[^file::load[text;$file]] 
<br>
^use[htedco.p]^htedco[text_edit;$f.text;20;80;^{	^}
^[	^]
(	)]
<br>
}{^die[232;Файл не найден]}

@edittmpblock[file][f;f1]
$fname[^file:basename[$file]]
^if($env:REQUEST_METHOD eq POST){$f[$form:$fname]
$f1[^content_prepare[$f]]
^if(!def $errors){^f1.save[$file]}
}
^if(-f $file){$f[^file::load[text;$file]]
<br>
^use[htedco.p]^htedco[$fname;^taint[as-is][^content_foredit[$f.text]];20;80;^[	^]	macro
<	>]

<br>
}{^die[232;Файл не найден]}


@headquotes[str]
$str[^str.match["+][ig]{"}]
$str[^str.match[(\s|^^)(")(\w)][ig]{${match.1}«$match.3}]
$str[^str.match[(\w)(")(\s|^$)][ig]{${match.1}»$match.3}]
$str[^str.replace[^table::create{f	t
",	»,
".	».
"-	»-
-"	-«}]]
$result[$str]
@content_prepare[co][con;rep1]
$con[^co.trim[]]
$con[^con.match[http://$env:SERVER_NAME/][ig]{/}]
$con[^con.match[(<img [^^>]*)src="([^^"]+)"([^^>]*>)][ig]{${match.1}src="^findpic[$match.2]"${match.3}}]
$con[^con.match[\^^+][ig]{^^^^^^^^}]
$rep1[^table::create{from	to
[	^^mod_prepare^[
^$	^^mod_prepare^[special^;dollar]
^taint[^#0A]@	^taint[^#0A] @}] $con[^con.replace[$rep1]]
$con0[^try{^process{^taint[as-is][$con]}}{ $result[] $errors[y] ^die[425;Обнаружены ошибки в теле страницы!] $exception.handled(1)}]
^if(!def $errors){$result[$con0]}
^memory:compact[]


@content_foredit[data][rep]
$data[^data.match[&(nbsp|quot|gt|lt|amp)][ig]{&amp^^^;$match.1}]
#^msg[^allowed_modules.foreach[k;v]{^$.${k}[$v] }]
$rep[^table::create{from	to
^^exec_module[	^^mod_foredit^[
^^exec_file[	^^mod_foredit^[
^^exec_sub[	^^mod_foredit^[
^^wiki[	^^mod_foredit^[
^^wikib[	^^mod_foredit^[}] $femodules[^hash::create[]]
$result[^try{^process{^data.replace[$rep]}}{^if(def $form:p){$exception.handled(1)^die[Correct the following: ^untaint[html]{$exception.comment}]^die[$form:content]}}]


@mod_foredit[mod;set;q1;q2;q3;q4;q5;q6;q7;q8;q9]
^try{^foredit1[$mod;$set]}{$exception.handled(1)$result[--Ошибка в коде--]}$femodules.$mod(1)
@foredit1[mod;set][md]
$result[[$mod^if(def $set){^;^if($set is hash){^set.foreach[k;v]{$k==$v}[,,]}{$set}}]]

@findpic[pica][pc;pic]
$pic[^file:basename[$pica]]
^if(-f "/my/img/a/$pic"){$pc[/my/img/a/$pic]}{^if(-f "/my/img/b/$pic"){$pc[/my/img/b/$pic]}{$pc[$pica]}}
$result[$pc]

@ext_hrefs[txt;linkid][text;txt1]
$txt1[^process{$txt}]
$result[^txt1.match[<a[^^>]+href=([^^ >]+)[^^>]*>(.*?)</a>][ig]{<a href="^ext_hrefs001[$match.1;$linkid]">${match.2}</a>}]

@ext_hrefs001[arg;linkid][a;result1]
$a[^arg.trim[both;"']]
^if(^a.pos[http://] == 0 || ^a.pos[ftp://] ==0 || ^a.pos[mailto:] ==0 || ^a.pos[nntp://] ==0){
$result1[$a]
}{
$result1[http://$env:SERVER_NAME/^a.trim[start;./]]
}
^if(def $linkid){
$result[$result1^if(^result1.pos[?] >= 2){&linkid=$linkid}{?linkid=$linkid}]
}{$result[$result1]}

@CLASS
pseudoname
@auto[]
^try{$names[^table::load[/my/config/pseudonames.txt]]
}{^blad[]$names[^table::create{param	value}]}
$names_searched(0)
@find[latin]
$result[^if(^names.locate[param;$latin]){$names.value}{$latin}]

