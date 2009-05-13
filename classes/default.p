@version[]
2009-04-13	v 3/1
2008-08-09	defselect, mailsend (for connect errors), qbuild(request builder)
2008-07-20	str2tbl, tbl2str
2008-07-11	@tagcloud - class "tag" et minora
Git staging test
2 test
Branch

@auto[]
^load_config_tables[]
^resmeter[core;default.p + config -- auto.p]
^load_custom_modules[]
$menu[^hash::create[]]$now[^date::now[]]

#operators for user error handling
@die[text;nothing]
$errmsg[^if(def $errmsg){$errmsg
^errmsg3[$text](1)}{^errmsg3[$text](1)}]
#^rec_id[$text]
@msg[text;nothing]
$errmsg1[^if(def $errmsg1){$errmsg1
^errmsg3[$text]}{^errmsg3[$text]}]
#^rec_id[$text]
@errmsg3[txt;die]
$result[^if(^txt.int(0) > 0){^if($die && def ^cando[] && def $globals.numerate_msgs){$txt }^lang[$txt]}{$txt}]
@lang[id;comment;o][lang;tmp]
^try{$lang[$globals.language]^if(!$lflag$lang){$ldat$lang[^hashfile::open[/my/deriv/$lang]]$lflag$lang(1)}
$result[^if(^id.int(0) > 0){$tmp[$ldat$lang.$id]^if(def $globals.numerate_msgs && def ^cando[] && ^tmp.length[] > 12){$id }$tmp}{$id}]
}{$exception.handled(1) $result[hashfErr!]}
@cando[c][check]
$check[$c] ^if(!def $usercando){$usercando[^hash::create[]]}
^if(def $usercando.deity){$result[1]}{ ^if($check is hash){}{$check[^s2h[$check]]} ^if(^check.intersects[$usercando]){$result[1]}{$result[]} }
#$result[1]
@resmeter[process;msg][locals]
$g[$globals.debug_load_msg]^if($g eq all || $g eq $process){$v[$status:rusage]^msg[$v.utime/$v.stime sec, $v.maxrss/$status:memory.used kb at "$msg"]}

@hasrig[c][check]
$check[$c]
^if($check is hash){}{$check[^s2h[$check]]} ^if(^check.intersects[$usercando]){$result(1)}{$result(0)}
@verbose[yes;no][l]
^if(def $usercando.demo){
$l[^default[$language;$globals.language]]
^if(!def $verbose){^try{^use[verbose.$l] }{$exception.handled(1)$verbose[^hash::create[]]}}
$verbose.$yes
}

@qbuild[params][qfile;ff;tmp]
$tmp[^request:uri.split[?;lh]]
$qfile[$tmp.0]
$ff[$form:fields]
$tmp[^expand[$params;=;&]]
^tmp.menu{
	^if(def $tmp.value){
		$ff.[$tmp.param][$tmp.value] 
	}{$ff.fff[$tmp.param]
		^ff.delete[$tmp.param]
	}
}
$result[$qfile?^ff.foreach[k;v]{$k=$v}[&] ]

@fdhash[vn;has][tmp]
^if(!def $caller.$vn){$caller.$vn[^if(def $has){$has;^hash::create[]}]}

@fdnum[var;value]
^if(!$caller.$var){$caller.$var(^value.double(0))}

@fddate[var;da]
^if($caller.$var is date){;$caller.$var[^date::create[$da]]}

@usePHP[fileName;smth][file]
$file[^file::load[text;http://$env:SERVER_NAME/$fileName;
	$.form[$form:fields]
#можно доделать и cookies (самостоятельно),
#см. http://www.parser.ru/docs/lang/fileload.htm
]]
^untaint{$file.text}


@htmltable[tab][locals] #any table into html view
$tc[^tab.columns[c]]
<table border="1" class="htmltable">
<tr>^tc.menu{<td><b>$tc.c</b></td>}</tr>
^tab.menu{
	<tr>^tc.menu{<td><b>$tab.[$tc.c]</b></td>}</tr>
}
</table>
@tbl2str[src;tab;new][ts]
^if(!def $tab){$tab[==]}^if(!def $new){$new[,,]}$ts[^src.columns[]]
$result[^ts.menu{$ts.column}[$tab]${new}^src.menu{^ts.menu{$src.[$ts.column]}[$tab]}[$new]]
@str2tbl[src;tab;new][rep]
^if(!def $tab){$tab[==]}^if(!def $new){$new[,,]}
$rep[^table::create{from	to
$tab	^taint[^#09]
$new	^taint[^#0A]}]
$result[^table::create{^untaint{^src.replace[$rep]}}]

@path_splitter[path][p;r;s;pt] #returns result table and $max_level variable
$p[^path.mid(1)] $pt[^p.split[/]] $r[^table::create{uri	level
/	0}] $max_level(0)
^pt.menu{$s[$s/$pt.piece] ^r.append{$s	^pt.line[]} $max_level(^pt.line[])}
$result[$r]

@pathlevel[path][pt]
$pt[^path.split[/;v]]
$result(^eval(^pt.count[] - 1))

@rn[i;optional]
^if(def $optional){^if(def ^cando[]){$result[${i}rn=^math:random(99999)]}{$result[]}}{$result[${i}rn=^math:random(99999)]}
@default[a;b]
$result[^if(def $a){$a}{$b}]
@md5[str][tmp]
$tmp[^math:md5[$str]]$result[^tmp.lower[]]

@redirect[url;code;time;msg]
$response:content-type[$.value[text/html]$.charset[$response:charset]]
#под виндой 301 глючит
#$response:status[^default[$code;301]]
#$response:Location[$url]
$response:refresh[$.value[^time.int(0)] $.url[^untaint{$url}] ]
$response:body[<html>
<head><title>Перенаправление...</title></head>
<script type="text/javascript">
location.replace("^taint[js][$url]")
</script>
<body>
<table align=center valign=center border=0><tr><td>
<b>$msg</b><p>
^lang[317] <a href="$url">^lang[318]</a>
</td></tr></table>
#for [x] MSIE friendly
^for[i](0;512/8){<!-- -->}
</body>
</html>]

@call_js[path][scr]
$scr[^file:justname[$path]]
^if($called_scripts is hash){;$called_scripts[^hash::create[]]}
^if(!$called_scripts.$scr){
<script language="javascript" src="$path"></script>
$called_scripts.$scr(1)
}

@tabindex[]
^tabindex.inc(1) tabindex="$tabindex"


@tree_sort[tree][g;h]
$g[^s2h[1 2 3 4 5 6 7]] $h[^hash::create[]]
^tree.menu{
$g.[$tree.level]($tree.sect_order) ^for[i]($tree.level + 1;7){$g.$i(0)}
 $h.[$tree.sect_key][^for[i](1;7){^g.$i.format[%03.0f]}]
}
^tree.sort{$h.[$tree.sect_key]}[asc]
$result[$tree]


@wisetrim[str;len;match][locals]
^if(def $match){$str[^str.match[(<[^^>])([^^>]*>|^$)][ig]{}]}
$str1[^str.left($len)]
$str2[^str.mid($len;23)]
$sadd[]
^for[i](0;23){$tmp[^str2.mid($i;1)]^if($tmp eq " "){^break[]}{$sadd[${sadd}$tmp]}}
$result[${str1}$sadd]

@sitemap[set;d][eye;pic]
^if($set is hash){}{$set[^hash::create[]]}^if(!def $set.path){$set.path[$uri]} $set.path[^set.path.trim[end;/]/]
^connect[$scs]{
$sitemap[^table::sql{SELECT s.path, s.sect_order, s.sect_key, ^if(def $set.bydate){1 AS level}{s.level}, s.menutitle, se.pagetitle, se.description, se.picture, s.rpermission, s.epermission, s.visiblity, s.module,
^if(def $globals.IUseFiles){'y' AS exist}{CASE se.content WHEN '' THEN '' ELSE 'y' END AS exist}
^combine_s_se[] WHERE s.path LIKE '$set.path%' ^if(def $set.limit){AND level <= '^eval(^pathlevel[$set.path] + ^set.limit.int(2))'} ^if($set.path eq "/"){AND s.path != '/'}
^if(!def ^cando[$erpermission] && !def ^cando[$.editor(1)]){^if(!def $globals.includeNoMenu){AND s.visiblity LIKE 'yes'}{AND s.visiblity NOT LIKE 'no'}}
ORDER BY ^if(def $set.bydate){s.created DESC}{s.path}}]
}$sitemap[^tree_sort[$sitemap]]
^if($sitemap_design is junction){^sitemap_design[$sitemap]}{
 <table border=0 cellspacing=0 cellpadding=1>
 $eye{^if($sitemap.visiblity ne yes){<img src="/login/img/eye.gif" align=baseline title="Закрыто">}}
 $pic{^if(def $set.showpic && def $sitemap.picture){^if(-f "/my/img/node_pics/$sitemap.picture"){<a href="$sitemap.path"><img src="/my/img/node_pics/$sitemap.picture" border="0" /></a><br>}}}
 ^sitemap.menu{$otstup(^eval($sitemap.level - ^pathlevel[$set.path] -1))
 <tr><td style="padding-left:^eval($otstup * 20)px^; padding-top:8px">$eye<a href="$sitemap.path">^default[$sitemap.pagetitle;$sitemap.menutitle]</a><br>$pic ^if(def $sitemap.description){$sitemap.description <a href="$sitemap.path">&gt^;&gt^;</a>}</td></tr>
 }
</table>
}
@combine_s_se[]
FROM ^dtp[structure] s LEFT JOIN ^dtp[sections] se ON s.sect_key = se.sect_key

#Выводит знаки, которые отрубаются внутри макросов: $, [, ], неразрывный пробел, <, >
@special[char;d][chr]
$chr[$.USD[^$]$.lc[^[]$.rc[^]] $.nbsp[&nbsp^;] $.gt[&gt^;] $.lt[&lt^;] $.opentag[<] $.closetag[>]]
$result[$chr.$char]
@email[email;d]
<script language=javascript>var dog="@"^;document.write ("<a href=mailto:^email.match[@][i]{"+dog+"}>^email.match[@][i]{"+dog+"}</a>")</script>
@notlogin[data;d]
^if(!def $user.id){$data}
@islogin[data;d]
^if(def $user.id){$data}
@var[var;u]
$result[^if(def $var){$local.$var}{$local.string}]



@saveable[string;p][rep;str]
$rep[^table::load[/login/config/saveable.txt]]
$str[^string.replace[$rep]]
$result[^taint[file-spec][$str]]
@translit[string;p]
^if(!def $translit_table){$translit_table[^table::load[/login/config/translit.txt]]}
$result[^string.replace[$translit_table]]
@dmy[arg][tmp]#->10.04.2008
^try{$tmp[^date::create[$arg]]
 $result[^eval($tmp.day)[%02.0f].^eval($tmp.month)[%02.0f].${tmp.year}]
}{$exception.handled(1) $result[$arg]}
@ufdate[arg][locals]#-> вчера в 20:00
^try{$d[^date::create[$arg]]
	$yesterday[^date::now(-1)]
		^if($d.day == $now.day && $d > $yesterday){^lang[585] $evh(1)}{
			$dby[^date::now(-2)]
			^if($d.day == $yesterday.day && $d > $dby){^lang[586] $evh(1)}{
				$dbby[^date::now(-3)]
				^if($d.day == $dby.day && $d > $dbby){^lang[587] $evh(1)}
			}
		}
^if($evh){в ${d.hour}:^d.minute.format[%02.0f]}{^dmy[$arg]}
}{$exception.handled(1) $result[$arg]}

#needs tab: name -> score -> ?title
@tagcloud[tab;url;div;mv;lim;opt][tv;mid]
^if(!^mv.int(0)){$mv(1)
^tab.menu{^if(^tab.score.int(0) > $mv){$mv($tab.score)}}
} ^if(!$lim){$lim(17)} ^if(!def $div){$div[, ]}
^tab.sort($tab.score)[desc]
$tab[^table::create[$tab][$.limit($lim)]]
^tab.sort{$tab.name}[asc]
$mid(0)^tab.menu{^mid.inc($tab.score*27/$mv)}$mid($mid/^tab.count[]/3)
^tab.menu{$tv(^math:round($tab.score*(27-$mid)/$mv))^if($tv < 10){$tv(10)}
<nobr><a class="tag" href="$url=$tab.name"><span class="tagspan" style="font-size:${tv}px">$tab.name^if(def $opt.score1){ ($tab.score)}</span></a></nobr>}[$div]

@attach_file[data][file;text;f]
^if($data is hash){$file[^saveable[$data.file]]$text[$data.text]}{$file[^saveable[$data]]}
^if((def ^cando[$.editor(1)] || def ^cando[$epermission]) && def $file){
^if(def $form:attach_file$file){
  $f[$form:attach_file$file]
  ^f.save[binary;/img/files/$file]
}
<form action="$uri" method=post enctype="multipart/form-data" style="display:inline">
<input type=file name=attach_file$file><br><input type=submit value="^lang[334]">
</form>

}
^if(-f "/img/files/$file"){^untaint{$text} ^if(-f "/img/icons/^file:justext[$file].gif"){<img src="/img/icons/^file:justext[$file].gif" border=0 align=baseline>}<a href="/img/files/$file">$file</a>}

@preformat[data;p]
<pre><font size=2>^taint[as-is][^if($data is hash){}{$data}]</font></pre>


@admin_inpage[div;pre;post]
^if(def ^cando[$epermission] || def ^cando[$.editor(1)]){
$pre
^use[/login/auto.p]
^get_admin_menu[]
<b>^lang[456]</b>$div
<a href="/login/update.htm?p=$uri^rn[&]">^lang[210]</a>$div
^rem{
<script language="Javascript1.2"><!--
var win_ie_ver = parseFloat(navigator.appVersion.split("MSIE")[1])^;
if (win_ie_ver = "") { win_ie_ver = -1 }^;
if (navigator.userAgent.indexOf('Mac')        >= 0) { win_ie_ver = 0^; }
if (navigator.userAgent.indexOf('Windows CE') >= 0) { win_ie_ver = 0^; }
if (navigator.userAgent.indexOf('Opera')      >= 0) { win_ie_ver = 0^; }
if (win_ie_ver >= 5.5) {
  document.write('<a href=$uri?editcontent=on^rn[&]>^lang[294]</a>')^;
}
// --></script>$div
}
<a href=$uri?editcontent=on^rn[&]>^lang[294]</a>$div
^if(def ^cando[editor]){<a href="/login/update.htm?add=^cut_end[$uri]^rn[&]">^lang[457]</a> $div}
<a href="/login/update.htm?add=$uri^rn[&]">^lang[458] &quot^;$document.menutitle&quot^;</a> $div
^menu.a.menu{<a href="$menu.a.uri">$menu.a.menutitle</a>}[$div]
$post
}

@utf2win[txt]
^if($tUTF2win is table){;$tUTF2win[^table::load[/login/config/utf2win.txt]]}
$result[^txt.replace[$tUTF2win]]

@multi2singletag[tab;div;col][tg;a]
$tg[^hash::create[]] ^if(!def $div){$div[,]} ^if(!def $col){$col[name]}
^tab.menu{
	$tmp[^tab.$col.split[$div;v]]
	^if(^tmp.count[]>0){^tmp.menu{
		$a[^tmp.piece.trim[]]
		^if(def $tg.$a){^tg.$a.inc(1)}{$tg.$a(1)}
	}}
}
$result[^table::create{name	score
^tg.foreach[k;v]{$k	$v}[
]}]$tg[]

@titleadd[text]
$document.pagetitle[$document.pagetitle $text]
$document.title[$document.title $text]

@titlerep[text]
$document.pagetitle[$text]
$document.title[$text]

@compact[tbl;tab;new][locals]
^if(!def $tab){$tab[==]}
^if(!def $new){$new[,,]}
$result[^tbl.menu{${tbl.param}${tab}${tbl.value}}[$new]]
@expand[str;tab;new][locals]
^if(!def $str){$str[ ]}^if(!def $tab){$tab[==]}^if(!def $new){$new[,,]}
$expand_replace[^table::create{from	to
&tab	^taint[^#09]
$tab	^taint[^#09]
$new	^taint[^#0A]
^taint[^#0A]	
^taint[^#0D]	}]
$result[^table::create{param	value	value2
^untaint{^str.replace[$expand_replace]}}]

@db_fld2showinlist[tab][t]
^if($dw_$tab is table){;$dw_$tab[^table::load[/my/dbs/${tab}.txt]]}
$t[$dw_$tab]
$result[
^t.offset[set](1)
$.1[$t.column]
^t.offset(1)
$.2[$t.column]
^t.offset(1)
$.3[$t.column]
]

@cut_end[path][ry;res]
$ry[^path.split[/;v]]
$res[^ry.menu{^if(^ry.line[] != ^ry.count[] && def $ry.piece){/$ry.piece}}]
$result[^default[$res;/]]

@nest[set;param]
^if($set is hash){^set.foreach[k;v]{^if($v eq clear){^placeblock.delete[$k]}{$placeblock.$k[$v]}}}

@keepvalue[id][id0]
$id0[^s2h[$id; ]]
^id0.foreach[k;v]{
 ^if(def $form:$k){<input type=hidden name="$k" value="$form:$k">}
}
@is_from_site[]
$result(^if(^env:HTTP_REFERER.pos[$env:SERVER_NAME] >= 0 || !def $env:HTTP_REFERER){1;0})

@icontent[text;auto][pc]
$pc[^try{^process{^untaint{$text}}}{$exception.handled(1)^if(^is_j[]){^lang[459]}}]
$result[^if($auto eq no){$pc}{^pc.replace[^unbrul[]]}]

@mailsend[mail]
^try{^mail:send[$mail]}{
	^if(^exception.type.left(4) eq "smtp"){
		$exception.handled(1)
		^die[^exception.type.upper[] ERROR ($exception.comment)]
		^mail.foreach[k;v]{^msg[$k : $v]}
	}
}

@ftext[name;value;size;class]
<input type=text name="$name" value="$value" size="$size" class="$class">
@fbool[name;value;checkvalue]
<input type="checkbox" name="$name" value="$value"^if($value eq $checkvalue){ checked}>
@select_language[name;checkvalue]
^if(def $langs){}{$langs[^table::load[/login/config/langs.txt]]}
^langs.menu{
   <input type=radio name="$name" value="$langs.langs"^if($langs.langs eq "$checkvalue"){ checked}>$langs.langs
  }
@fradio[name;listvalues;checkvalue][vl]
$vl[^listvalues.split[ ;v]]
^vl.menu{<input type=radio name="$name" value="$vl.piece"^if("$vl.piece" eq "^default[$checkvalue;$form:$name]"){ checked}> $vl.piece}
@defselect[tab;value]
$tab[^table::create{n	v
^untaint{$tab}}]
^tab.menu{<option value="$tab.n"^if($value eq $tab.n){ selected}>^default[$tab.v;$tab.n]</option>}

@is_email[email]
$result(^if(def $email && ^email.match[^^\w+([.-]?\w+)+\@\w+([.-]?\w+)*\.[a-z]{2,4}^$][i]){1}{0})

@noser_div[divider;id]
^if(def $noserial$id){$result[$divider]}{$result[] $noserial$id[1]}

@sqldate[arg][md]
^try{$md[^date::create[$arg]]$md[^md.sql-string[]]}{$exception.handled(1)$md[^now.sql-string[]]}
$result[$md]

@sql_request_hash[grp;field][hh]
$hh[^s2h[$grp]]
$result[^if(def $hh){^hh.foreach[k;v]{$field = '$k'}[ OR ]}{ 0 }]

@formtables_def[field][mh]
$mh[$form:tables.$field]
^if($mh is table){;$mh[^table::create{field}]}
$result[$mh]

@mergeftext[files][locals]
$files[^table::create{file
$files}]
^files.menu{
	^try{$tmp[^file::load[text;$files.file]]$fh[$fh
$tmp.text]}{^blad[]}
} $result[$fh]
#########################################









##########################################
#############old /auto.p##################
##########################################

@blad[oi]
$caller.exception.handled(1)
^if(def $oi){^die[$oi]}

@dtp[table]
$result[${startup.db_tbl_prefix.value}$table]

@document[params][fd]
^if(!def $environment_created){^environment[]}
^if(def $design){
  ^if(-f "/my/templates/$design"){$design[/my/templates/$design]}{
    ^if(-f "/login/templates/$design"){$design[/login/templates/$design]}{$design[]}
  }
}
^if(!def $design){$design[/login/templates/_default.html]}
^if(def $cookie:myDesign && -f "/my/templates/$cookie:myDesign"){$design[/my/templates/$cookie:myDesign]}
^if(def $form:mode_printable && def $globals.enablePrint && ^is_from_site[]){$design[/my/templates/_print.html]}
^if(def $params.design){^use[$params.design]}{^use[$design]}
$prepared_content[^get_content[]]
^construct_headers[]
^design[^get_header[];$document.pagetitle;$prepared_content]

@load_custom_modules[]
$mmodules[^file:list[/my/autorun]]
^mmodules.menu{
 ^use[/my/autorun/$mmodules.name]
 ^try{$allowed_modules[$allowed_modules ^allowed[]]}{$exception.handled(1)}
}
$allowed_modules[$allowed_modules var correctme email special program sitemap notlogin islogin translit nest redirect]
$allowed_modules[^s2h[$allowed_modules]]

@get_header[]
<title>$document.title</title>
<meta name="keywords" content="$document.keywords">
^if(def $document.description){<meta name="description" content="$document.description">}
<!-- ^#41k^#74a^#72 ^#43M^#53 -->
^if(def $globals.jqueryOn){
	^call_js[/plugins/jquery.js]
	^call_js[/login/scripts/user.js]
	<link rel="stylesheet" href="/login/styles/ajax.css" type="text/css" />
}
@get_content[][f;rep0]
^if(def $form:editcontent){^use[visualeditor.p] ^visualeditor[]}{
^if(!def $doptions.exec){$process_body(0)}
$precontent[^if(def $doptions.unbrul){^document.content.replace[^unbrul[]]}{$document.content}]
^if($process_body){^process{^untaint{$precontent}}}{^untaint{$precontent}}
^if(def $document.module && !def $module_already_executed){
  ^exec_sub[$document.module;^expand[$document.module_settings]] ^rem{bottom}
}
}

@rec_id[str]
#^if(!def $tlog){$tlog[^table::load[nameless;/lang.log]] }
#^if(!def ^tlog.locate[0;$str]){^tlog.append{$str}}
$result[]

@load_config_tables[][tmp]
$tmp[^table::load[/^if(-f "/local"){aktar_mysql_local;aktar_mysql}.cfg]]
$startup[^tmp.hash[var]]
$dtp[$startup.db_tbl_prefix.value]
$scs[$startup.sql_conn_string.value] $SQL.connect-string[$scs]
^try{
	$tmp[^file::load[text;/my/deriv/globals.p]]
	$globals[^h2s:createh[$tmp.text]] 
}{^blad[]$globals[^hash::create[]]}
^if(^globals.timeout.int(0) < 1){$globals.timeout(2)}
^if(!def $globals.language){$globals.language[en]}
@environment[path][str;tbl]
^manage_session[]
$menu[^hash::create[]]
^if(def $path){$str[$path]}{$str[$request:uri] $tbl[^str.split[?;h]] $str[$tbl.0]}
$str[^str.split[,;lh]] $main_argument[$str.1] $str[$str.0]
$uri[^str.trim[end;/]] $iffile[^str.split[.;h]] $str[$iffile.1] ^if(def $uri){}{$uri[/]} 
^create_document[$uri]
$environment_created[y]

@create_document[uri][tmp] #each document contains page hash, all menu tables and breadcrumb table. May not be available if user has no permission to view hidden table
$path_t[^path_splitter[$uri]]  $path_hash[^path_t.hash[uri][$.distinct(1)]] $placeblock[^hash::create[]]
^for[i](0;$max_level){$menu.$i[^table::create{sect_order	uri	menutitle	current	visiblity	module}]}
$crumbs[^table::create{uri	menutitle}]
^connect[$scs]{
#Get crumbs, additional menus and build all inherits
$inher[^sqlcache[
	SELECT * FROM ^dtp[structure] 
	WHERE path IN (^path_t.menu{'$path_t.uri'}[, ]) 
	ORDER BY level ASC 
;^if(def ^cando[editor]){-1;120}]]
  ^inher.menu{
    ^if(def $inher.design){$design[$inher.design]}
    ^if(def $inher.language){$language[$inher.language]}
    ^if(!def $invisible){^if($inher.visiblity eq no){$invisible[$inher.level]}}
    ^if(def $inher.epermission){$epermission[$epermission $inher.epermission]}
    ^if(def $inher.rpermission){$rpermission[$rpermission $inher.rpermission]}
    ^if(def $inher.add_block){^getblocks[$inher.add_block]}
    ^crumbs.append{$inher.path	$inher.menutitle}
  }
$epermission[^s2h[$epermission editor; ]]
$rpermission[^s2h[$rpermission editor; ]]
#find visiblity restrictions
$erpermission[^hash::create[]] ^erpermission.add[$rpermission] ^erpermission.add[$epermission]
^if(def $invisible && !def ^cando[$erpermission]){$path_t[^path_t.select($path_t.level < $invisible)]}
#Build all menus
$menus[^sqlcache[
	SELECT sect_key, path, level, menutitle, sect_order, rpermission, epermission, visiblity, module 
	FROM ^dtp[structure] WHERE  
	^path_t.menu{ 
		(^if($path_t.uri ne "/"){path LIKE '$path_t.uri/%' AND} 
		level = '^eval($path_t.level + 1)' ) 
	}[ OR ] 
;^if(def ^cando[editor]){-1;120}]]
^if(def $usercando){^ifUser[]}{^ifNoUser[]}
^for[i](0;$max_level){^menu.$i.sort($menu.$i.sect_order)}
#Get current document
^select_node[$uri]
}
$menus[] $document0[]
^if(def $http_error){^use[errors.p]  ^errorHandler[$http_error]}
#######adds a block to inherited blocks (hash)
@getblocks[b][bl]
$bl[^expand[$b]]
^bl.menu{$placeblock.[$bl.param][$bl.value]} $result[]
@select_node[uri][f;dt]
^inher.offset(-1)
^if($inher.module eq "swapcontent.p"){^try{
	^use[/login/modules/swapcontent.p]
	$docpath[^swap_path[$inher.path]]
}{
	$exception.handled(0)
	$docpath[$uri]
}}{$docpath[$uri]}
$document0[^table::sql{SELECT s.sect_key, s.*, se.* FROM ^dtp[structure] s 
LEFT JOIN ^dtp[sections] se ON s.sect_key = se.sect_key WHERE s.path = '$docpath'}]
$document[$document0.fields]
  ^if(def $document0){
    ^if($document.visiblity eq no){^if(!def ^cando[editor $document.rpermission $document.epermission]){$http_error[403]}}
  }{$http_error[404]}
$doptions[^s2h[$document.this_settings; ]]
^if(def $document.asfile && -f "/my/file_content$document.asfile"){
		$f[^file::load[text;/my/file_content$document.asfile]] $dt[^f.text.split[@content[]
;lh]] $document.content[$dt.1]}
^if(!def $document.content && !def $form:p && $globals.SubstElderSon eq yes && $document.module ne "sectionmap.p"){
	$document.content[^sitemap[]]
}
@ifUser[]
^menus.menu{
  $tmp(^eval($menus.level - 1))
  ^if($menus.visiblity ne yes){
    ^if(def ^cando[editor $menus.epermission $menus.rpermission]){^admit[$tmp]}
  }{^admit[$tmp]}
}
@ifNoUser[]
^menus.menu{
  $tmp[^eval($menus.level - 1)]
  ^if($menus.visiblity eq yes){^admit[$tmp]}
}
###a tail for @create_document[]
@admit[tmp]
^menu.$tmp.append{$menus.sect_order	$menus.path	$menus.menutitle	^if(def $path_hash.[$menus.path]){y}	$menus.visiblity	$menus.module}
###a tail for @create_document[]
@cut_menus_table[][doubler]
$path_t[^path_t.select($path_t.level < $invisible)]
 $result[]

@manage_session[new][user0;newsid]
^sleep(0)
^if(def $cookie:s){$sid[$cookie:s]}{^if(def $form:s){$sid[$form:s]}}
^if(def $new){$sid[$new]}
^if(def $sid && ^sid.length[] == 16){
^if($sessions is hashfile){;$sessions[^hashfile::open[/cache/set/sessions]]}
^try{$userid($sessions.$sid)}{$exception.handled(1)}
^sessions.release[]
  ^if($userid && !def $user){^connect[$scs]{
     $user0[^table::sql{SELECT u.id, u.name, u.lastname, u.email, u.rig, u.language, ug.rig AS group_rig  FROM ^dtp[users] u LEFT JOIN ^dtp[usergroups] ug ON u.groupid = ug.groupid WHERE u.id = '$userid'}]
     ^if(def $user0.language){$globals.language[$user0.language]}
  $user[$user0.fields] $user0[]
  }}{}
}
$usercando[^s2h[$user.rig $user.group_rig]] $userid($user.id) $username[$user.name $user.lastname]
^if($userid){^generate_session[]}
^if($user is hash){^use[/login/auto.p]}
@generate_session[]
^if(def $globals.regenerate_ses){
  ^sessions.delete[$sid] $sid[^math:uid64[]]
}
^try{$sessions.$sid[$.value[$user.id]$.expires(^ses_exp[])]
$cookie:s[$.value[$sid] $.expires(^globals.sessiontime.int(90))]
}{$exception.handled(1)^die[^lang[^untaint[html]{$exception.comment} $exception.file^(${exception.lineno}:$exception.colno^)]] ^die[Если вас выбросило, зайдите снова и отключите обновление сессий в настройках.]}
@ses_exp[]
^if(^hasrig[$globals.sessionlimit8]){$result(1/3)}{$result($globals.sessiontime)}

@include[file][f;ftx]
$fe[^math:md5[$file]]
#$f[^file:find[$file]]^if(def $f){$ftx[^file::load[text;$f]]^process[$caller.self]{^taint[as-is][$ftx.text]}[$.file[$file]]}
#$f[^file:find[$file]]^if(def $f){^if(!def $$fe){$$fe[^file::load[text;$f]]}^process[$caller.self]{^taint[as-is][$$fe.text]}[$.file[$file]]}
#^if(!def $$fe){$$fe[^file::load[text;$file]]}^process[$caller.self]{^taint[as-is][$$fe.text]}[$.file[$file]]
^if(!def $$fe){^try{$$fe[^file::load[text;$file]]}{$exception.handled(1)}}^process[$caller.self]{^taint[as-is][$$fe.text]}[$.file[$file]]
@include_exist[file][ftx]
$ftx[^file::load[text;$file]]
^process{^taint[as-is][$ftx.text]}

@unbrul[]
$result[^table::create{from	to
</p>^taint[^#0A]	</p>
r>^taint[^#0A]	r>
l>^taint[^#0A]	l>
^taint[^#0A]^taint[^#0A]	 <p>
^taint[^#0A]*	 <li>
^taint[^#0A]	 <br> }]

@placeholder[id;comment;settings][k;xec]
^if($settings is hash){}{$settings[^hash::create[]]}
$k[$placeblock.$id]
^if(def $k && $k ne clear){$settings.pre
  ^switch[^file:justext[$k]]{
  ^case[p]{^exec_file[$k]}
  ^case[cfg]{^exec_file[$k]}
  ^case[w]{^wikib[$k]}
  ^case[DEFAULT]{$k}
}$settings.post }{$settings.empty}
^if($placeholder_check){
^if(!def $phcount){$phcount[^hash::create[]]$phoptions[^hash::create[]]}
$phcount.$id[example.p]
$phoptions.$id[$comment]
}

@construct_headers[][mdd;dw;dm]
^try{$mdd[^date::create[^default[$document.modified;^now.sql-string[]]]]}{$exception.handled(1) $mdd[^date::now[]]}
^if(def $document.module){$mdd[^date::now(-6/24)]}
^if(!def $user.id || $globals.cache_time == 0){
$response:Last-modified[$mdd]
}{}
#$response:expires[^date::create($now)]
$result[]
@hashset[set][sts]
^if($set is hash){$result[^set.foreach[k;v]{^$.${k}[$v]}]}{
^if(^set.pos[,,] > 0 || ^set.pos[==] > 0){
$sts[^expand[$set]]
$result[^sts.menu{^$.$sts.param^[$sts.value^]}[ ]]}{
 $result[$set]
}}

@exec_file[file;set;p1;p2;p3;p4;p5]
^ihavenotime[]
^untaint{^try{^exec_file1[$file;$set]}{^if(def ^cando[]){^die[^lang[434] $file] }}}
@exec_file1[file;set][local;ftx]
^if($set is hash){$caller.local[$set]}{$caller.local[^hash::create[]] $caller.local.string[$set]}
^include[/my/blocks/$file]

@exec_module[module;set;p1;p2;p3;p4;p5][xec]
^ihavenotime[]
$xec[$$module] $result[^try{^xec[$set]}{
^if(!def ^cando[]){$exception.handled(1)}
^if(def ^cando[]){^die[^lang[435] $module]}}]

@correctme[edit_path;b]
^if(def ^cando[editor menu $b]){
<a href="^if(^edit_path.pos[/]>=0){$edit_path;/login/blocks.htm?block=$edit_path}" title="^lang[460]"><img border="0" src="/login/img/edit.gif" width="8" height="8" /></a>
}

@wiki[set;options;p1;p2;p3;p4;p5][tb;g]
$tb[^set.split[::;lh]]
$result[^showlink[$tb.0;$tb.1]]
@showlink[text;link;class]
^if(def $link && (^link.left(1) eq "/" || ^link.left(7) eq "http://")){
 $result[^if($request:uri ne $link){<a class="$class" href="$link">}^if(def $text){$text}{$link}</a>]
}{
 $result[<a class="$class" href="/login/w.htm?q=^taint[uri][^if(def $link){$link}{$text}]" class="wiki">$text</a>]
}
@wikib[block;set;p1;p2;p3;p4;p5][tb;rep;f;ft;j]
^if($set is hash){}{^if(def $set){$set[$.divider[$set]]}{$set[^hash::create[]]}} ^if(def $blocklink_settings && !def $set){$set[$blocklink_settings]}
^if(-f "/my/blocks/$block"){
$tb[^table::load[nameless;/my/blocks/$block]]
^tb.menu{$f[$tb.0]^if(^f.left(1) eq "\"){^f.trim[start;\]}{^showlink[$f;$tb.1;$set.class]}}[^default[$set.divider;<br>]]
}
#Выполняет подпрограмму
@exec_sub[sub;set;p1;p2;p3;p4;p5]
^ihavenotime[]
^try{^exec_sub1[$sub;$set]}{^lang[427] $exception.comment $exception.file^(${exception.lineno}:$exception.colno^) $sub
^if(!def ^cando[]){
$exception.handled(1)
}{
^lang[427] $sub default.p/exec_sub
$exception.handled(0)
}}
#Продолжает выполнять подпрограмму
@exec_sub1[sub;set][b;set1;sp]
$sub[^file:justname[$sub]]
^try{
^use[^modpath[${sub}.p]]
$set[^sub_hSet[$set]]
$set[^apply_globalsub[$set;$sub]]
$b[$$sub] $result[^b[$set]]
}{^if(def $form:p){$exception.handled(1)^die[^lang[461]]}}
#Создает хэш данных подпрограммы из стандартной==строки,, или таблицы
@sub_hSet[set]
^if($set is hash){}{
  ^if($set is table){}{$set[^expand[$set]]}$set1[^hash::create[]]
  ^set.menu{$sp[$set.param]$set1.$sp[$set.value]} $set[$set1]
}
$result[$set]
#Применяет глобальные настройки к подпрограмме
@modpath[mod]
^if($system_modules is hash){;$system_modules[^s2h[news.p forum.p swapcontent.p inbox.p userprofile.p search.p]]}
$result[^if(def $system_modules.$mod){/login/modules/$mod}{/modules/$mod}]
@apply_globalsub[set;sub]
$modval[^bmodval[$sub;$set]]
^modval.foreach[k;v]{
	^if(^mvcheck[$modval.$k;$k;$set.$k]){$set.$k[$modval.$k.value]}
}
$result[$set]
#Проверяет, надо ли использовать глобальную настройку
@mvcheck[modval;param;value]
$result(0)
^if( $modval.use == 1 && !def $value ||
	$modval.use == 2 && def $modval.r && ^uri.match[$modval.r] ||
	$modval.use == 3
){$result(1)}
#Загружает описание глобальных настроек для модуля
@bmodval[sub;set][modval]
$sub[/my/deriv/module_settings/^file:justname[$sub].p.mgs]
^try{
	$modval[^file::load[text;$sub]]
	$modval[^h2s:createh[$modval.text]]
}{
	$exception.handled(1)
	$modval[^hash::create[]]
}
$modval._default[$.use(0)]
$result[$modval]
@makepage[path]
$process_body(1)
^environment[$path]
^document[]
####Breaks page execution if reached time limit.
@ihavenotime[][d3;mytime]
$mytime(^globals.timeout.double[]) ^if(def $usercando.deity){^mytime.mul(8)}
$d3[^date::now[]]
^if(^eval(^d3.unix-timestamp[] - ^now.unix-timestamp[]) > $mytime){^throw[parser.interrupted;^lang[462]]}

@program[unuseful_data;d]
$module_already_executed[y]
^if(def $document.module){
^exec_sub[$document.module;^expand[$document.module_settings]]
}

@sqlcache[query;minutes;junk;alt_cache][locals;result]
$mdq[^default[$alt_cache;^md5[$query $junk]]]
$expdate[^date::now(-$minutes/1440)]
^try{
	^if($minutes <= 0){^throw[1;1]}
	$cache[^file::stat[/cache/sql/$mdq]]
	^if($cache.mdate < $expdate){^throw[1;1]}
	$result[^table::load[/cache/sql/$mdq;$.encloser[^#02]$.separator[^#03]]]
}{
	^if($exception.type eq "1" || 1){$exception.handled(1)}
	^connect[$scs]{
		$result[^table::sql{$query}]
	}
	^if($minutes > 0){
		^result.save[/cache/sql/$mdq;$.encloser[^#02]$.separator[^#03]]
	}
}

@choose_file[file1;file2]
$result[^if(-f "$file1"){$file1;$file2}]
@jqueryon[scr][locals]
$rct[$response:content-type] 
^if(def $globals.jqueryOn && $rct.value eq "text/html"){
	$ex[^file::load[text;^choose_file[/my/templates/ajax.htm;/login/templates/ajax.htm]]]
	^untaint{$ex.text}
	^if(!def $scr){<script language="javascript" src="/login/scripts/inits.js"></script>}{
	^call_js[$scr]
	}
}{$result[]}
@postprocess[body]
^resmeter[core;after all -- ./auto.p]
^if((def $errmsg || def $errmsg1) && $body is string){
$errmsg[^table::create{err
$errmsg}]
$errmsg1[^table::create{err
$errmsg1}]
$errrep[<span class="errmsg">^errmsg.menu{$errmsg.err<br>}<span class="errmsg1">^errmsg1.menu{$errmsg1.err}[<br>]</span></span>]
^body.replace[^table::create{from	to
<!-- errmsg-->	$errrep}]^jqueryon[]
}{$result[${body}^jqueryon[]]}
#^if(def $tlog){^tlog.sort{$tlog.0}^tlog.save[nameless;/lang.log]}

#########transforms string to hash, a|b|c -> $div[|] -> $.a(1) $.b(1) $.c(1)
#result must be assigned to new variable.
@s2h[str;div;def0][tmp;tmpt;tmph;str1]
^if(!def $div){$div[ ]}^if(!def $def0){$def0(1)}^if($str is hash){$result[$str]}{$tmp[^str.split[$div;v]]$tmph[^tmp.menu{^if(def $tmp.piece){$.[$tmp.piece]($def0)}}]}$result[^if($tmph is hash){$tmph}{^hash::create[]}]
@end[]

############################################
############################################
############################################













@CLASS
h2s

@createh[str]
^process{^taint[as-is; ^$hash_^[$str^] ]}
$result[^if($hash_ is hash){$hash_}{^hash::create[]}]

@h2o[hash_;div]
$result[^hash_.foreach[k;v]{$k}[^if(def $div){$div}{ }]]

@h2s[hash1;level][tmp;hh]
$hh(^level.int(0))^hh.inc(1)^hash1.foreach[k;v]{^if($v is hash){$tmp[^hash::create[$hash1.$k]]^$.$k^[^h2s[$tmp;$hh]]}{^$.$k^if($v is int || $v is double){($v)}{[^unparse[$v]]}}}

@unparse[t]
^if($unparser is table){;
$unparser[^table::create{from	to
^^	^^^^
^$	^^^$
^;	^^^;
^[	^^^[
^]	^^^]}]
}
$result[^t.replace[$unparser]]

@CLASS
pagination
#USAGE
#1. find qty: $qty(SELECT COUNT(*)) $pages1[^pagination::create($qty)(items_on_page)[reverse flag][additional string XXX to ?pageXXX=... for multiple paginations]]
#2. in selection: ^table::sql{SELECT ...}[^pages1.q[limits]]
#3. in pages list: ^pages1.listpages[ | ;$.url[/page?mode=full&]$.prescript[Pages:]$.beforeq[before_current]$.classq[CSS_current] afterq after class]
#OR $table[^pages1.listpages[returnTable]] makes nameless table: $table.0 = page number, $table.1 = (|current)

@create[count;it;rev;han]
$pcount($count) $items(^if($it){$it}{1}) $handler[$han] $reverse[$rev]
$cyc(^math:ceiling(^eval($count / $items)))
$curr(^if(def $reverse){^eval($cyc - $form:page$handler + 1)}{$form:page$handler})
^if(!$curr){$curr(1)}

@listpages[divider;settings][incodeq;incode;ii]
^if($pcount > $items){$settings.prescript}     $list2[^table::create[nameless]{}]
^if(def $reverse){$ii{^eval($cyc - $i + 1)}}{$ii{$i}}
$incodeq{$settings.beforeq<span class="$settings.classq">${ii}</span>$settings.afterq}
$incode{<a href="${settings.url}page$handler=$ii" class="$settings.class">${settings.before}${ii}${settings.after}</a>}
^if($pcount > $items){
  ^for[i](1;$cyc){
   ^if($curr == $i){$incodeq}{$incode}
   ^list2.append{$ii	^if($curr == $i){current}}
  }[$divider]
}
^if($divider eq returnTable){$result[$list2]}
@post_form[]
<input type=hidden name="page$handler" value="$curr">
@from[]
$result(^eval(($curr - 1) * $items + 1))
@to[]
$result(^eval($curr * $items))
@q[mode]
$offset(^eval($items * ($curr - 1)))
^if($offset < 0){$offset(0)}
^switch[$mode]{
 ^case[limit]{$result($items)}
 ^case[offset]{$result($offset)}
 ^case[limits]{$result[$.limit($items) $.offset($offset)]}
 ^case[DEFAULT]{$result[LIMIT $offset,$items]}
}



@CLASS
gridcontrol

@list[form;fieldlist;fieldnames;startUrl]
$fn[^fieldnames.split[, ;v]]
$fl[^fieldlist.split[, ;v]]
^fl.menu{
 <td><a href="${startUrl}${form}=${fl.piece}" title="^lang[426]">$fn.piece</a></td> ^fn.offset(1)
}

@CLASS
enum

@parse[data;comm;fn][rep;data1;comment]
$comment[^expand[$comm]]
$data1[^data.split[DEFAULT ;lh]]
$rep[^table::create{from	to
ENUM 	
ENUM	
(	
)	
'	
,	}]
$values[^s2h[^data1.0.replace[$rep];;0]]
^comment.menu{$values.[$comment.param][$comment.value]}
$default_value[^try{^data1.1.replace[$rep]}{$exception.handled(1)}]
$field_name[$fn]


@create[hash_;def;fn]
$default_value[$def]
$field_name[$fn]
$values[^hash::create[$hash_]]

@form[value_;tabindex]
$user_value[^default[$value_;$default_value]]
^values.foreach[k;v]{
 <input type="radio" name="$field_name" value="$k"^if($k eq $user_value){ checked}>^if(!$v){$k;$v}
}

@CLASS
hafala
@auto[]
$h[^hash::create[]]
@open[p][t]
^if($h is hash){;$h[^hash::create[]]}
$t[^md5[$p]]^if($h.$t is hashfile){;$h.$t[^hashfile::open[$p]]}$result[$h.$t]

@CLASS
ak
@auto[]
#creating an uri to use in documents - Like '/a/b' (not '/a/b/') or '/' if root
$tmp[^request:uri.split[?;lh]]
$tmp[^tmp.0.split[,;lh]] $MAIN:main_argument[$tmp.1]
$uri[^tmp.0.trim[end;/]]
^if(!def $uri){$uri[/]}
$MAIN:path[$uri]

#adding class pathes - only this way
$akpathlist[^s2h[/my/autorun /login/classes /login/modules]] $tmp[$MAIN:CLASS_PATH]
$MAIN:CLASS_PATH[^table::create{path
^if($tmp is table){^tmp.menu{^if(!def $akpathlist.[$tmp.path]){$tmp.path
}}}/login/classes}]

@GET_seo_uri[]
$result[^if(def $MAIN:globals.addIndexHtml){$uri^if($uri ne "/"){/}index.html}{$uri}]

@root_[][result]
#Cache definition
$cache_time(^MAIN:globals.cache_time.int(0))
$tmp[$env:REMOTE_ADDR]
^if($env:REQUEST_METHOD eq POST || ^tmp.left(7) eq "192.168" || ^tmp.left(6) eq "127.0." || ^pathlevel[$uri] > ^globals.cache_level.int(3)){
	$cache_time(0)
} 
^if(def $request:query){
	$cache_time(0)
}{
	$cache_file[^md5[$uri]]
}
^if(def $cookie:s){$cache_time(0)}

#macros is ON by default
$MAIN:process_body(1)

^if(!$cache_time){
  ^environment[]
  ^document[]
}{
  ^cache[/cache/www/$cache_file]($cache_time){
  ^environment[]
  ^document[]
  }{ $exception.handled[cache] ^msg[463] }
}

#pictures by default stored in 2 dirs, so if you lost a picture, just upload it
@find404pic[pica][pc;pic;dpic]
$pic[^file:basename[$pica]]
^if(def -f "/my/img/a/$pic"){$pc[/my/img/a/$pic]}{^if(def -f "/my/img/b/$pic"){$pc[/my/img/b/$pic]}{$pc[/login/img/spacer.gif]}}
$dpic[^file::load[binary;$pc]] $response:body[$dpic]
$pc[]
