@news_settings[options]
$result[^table::create{param	type	default	descr
id	string	$i[^uri.split[/;rh]]^i.0.left(32)	Идентификатор новостной ленты
rpp	num	15	Новостей на странице
#visual	bool	yes	Использовать визуальный редактор
more	string	$form:p	Путь к архиву новостей (если нужен)
readmore	string	Читать дальше&gt^;&gt^;	Текст "читать дальше"
nopages	bool	yes	Не выводить страницы
denyexport	bool	yes	Запретить экспорт в RSS
}]

@news_info[set][inf]
Права на редактирование новостей: news
$inf[^table::sql{SELECT DISTINCT newsid FROM ^dtp[news]}]
<br> Имеющиеся идентификаторы (непустые): ^inf.menu{$inf.newsid}[, ].
@news[set]

$seti[$set]
^if(!def $seti.id){$seti.id[default]$allid[^s2h[$seti.id]]}{$allid[^s2h[$seti.id]]$tmp[^seti.id.split[ ;lh]]$seti.id[$tmp.0]}
$cnews[^table::load[/my/dbs/news.txt]]
^connect[$scs]{
^if(^form:displaynew.int(0) > 0){^show1[$form:displaynew]}{^shownews[]}

^if(^is_j[]){
 ^editnews[]
}

}
^if(!def $seti.denyexport){
<a href="$uri?export=rss"><span style="background-color:#ff6600^;font-size:9px^;text-decoration:none^;color:#FFFFFF^;padding:2px^;letter-spacing:1px">rss</span></a>
}

@show1[i][rep]
$new[^getnew[$i]] ^if(!def $new.content){$new.content[ ]}
$rep[^table::create[nameless]{:more:	}]
$new.content[^icontent[^new.content.replace[$rep];$new.autoformat]]
$new.postdate[^dmy[$new.postdate]]
  ^titlerep[$new.title]
^if($new_design is junction){^new_design[]}{
$document.content[]  
<b class="newsb">$new.postdate</b><br>
<span class=new>$new.content</span>
<p>
^try{^comments[$new.id]}{^blad[]}
}
@icontent[text;auto][pc]
$pc[^try{^process{^untaint{$text}}}{$exception.handled(1)^if(^is_j[]){ошибка в данных}}]
$result[^if($auto eq no){$pc}{^pc.replace[^unbrul[]]}]
@shownews[]
$r(^int:sql{SELECT COUNT(id) FROM ^dtp[news] WHERE newsid IN (^allid.foreach[k;v]{'$k'}[, ]) })

^if(!def $seti.nopages){$pp[^pagination::create[$r;^seti.rpp.int(15)]]}
$news[^table::sql{SELECT n.*, count(f.fid) AS comments 
FROM ^dtp[news] n LEFT JOIN ^dtp[forum] f ON n.id = f.fid 
WHERE n.newsid IN (^allid.foreach[k;v]{'$k'}[, ])
^if(^is_j[]){}{AND n.postdate <= '^now.sql-string[]'}
 
GROUP BY n.id ORDER BY n.postdate DESC}[^if(!def $seti.nopages){^pp.q[limits]}]]
<form action="$uri?a=del_multiple" style="display:inline">
^if(def $form:export && !def $seti.denyexport){
	$response:body[^xmlexportnews[$news;$form:export]]
}{
^if($news_design is junction){^news_design[$news]}{
^news.menu{
  <h3>$news.title </h3>
  ^dmy[$news.postdate]
  (<a href="^default[$seti.more;$uri]?displaynew=$news.id&akcomm=open#comf">^if(^news.comments.int(0)){комментариев: $news.comments}{оставить комментарий}</a>)
  ^if(^is_j[]){<input type=checkbox name=dd value="$news.id">удалить <a href="$uri?displaynew=$news.id">редактировать</a> }
  <br>  <span class="new"> ^content_in_new[$news.content;$news.autoformat]</span>

  <br> 

}

}
}
#ifdesign end
^if(^is_j[]){ <input type=submit value="Удалить выбранные">}
</form>
^if(!def $seti.nopages){^pp.listpages[ | ;$.url[$uri?]$.prescript[Страницы:]]}{
	^if(def $seti.more){<a href="$seti.more">Архив новостей</a>}
}

@xmlexportnews[news;mode]
$response:charset[UTF-8]
$response:content-type[
        $.value[application/rss+xml]
        $.charset[$response:charset]
]
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
    <title>^taint[xml][^default[$document.pagetitle;$document.menutitle]]</title>
    <link>http://${env:SERVER_NAME}$uri</link>
    <description>^taint[xml][^default[$document.description;$document.title]]</description>
    <language>ru</language>
    <pubDate>^now.gmt-string[]</pubDate>
 $LBD[^date::create[$news.postdate]]
    <lastBuildDate>^LBD.gmt-string[]</lastBuildDate>
    <docs>http://blogs.law.harvard.edu/tech/rss</docs>
    <generator>Aktar CMS</generator>
    <managingEditor>$globals.site_admin</managingEditor>
    <webMaster>$globals.site_admin</webMaster>
    ^news.menu{
    <item>
      <title>^taint[xml][$news.title]</title>
      <link>http://${env:SERVER_NAME}$uri?displaynew=$news.id</link>
      <description>^taint[xml][^content_in_new[$news.content;$news.autoformat]]</description>
      $PD[^date::create[$news.postdate]]
      <pubDate>^PD.gmt-string[]</pubDate>
      <guid>http://${env:SERVER_NAME}$uri?displaynew=$news.id</guid>
    </item>
    }
</channel>
</rss>

@content_in_new[text;auto][txt]
$tmp[^text.split[:more:;lh]]
^icontent[$tmp.0;$auto]
^if(^tmp.1.length[] >= 1){<nobr><a href="http://${env:SERVER_NAME}^default[$seti.more;$uri]?displaynew=$news.id">^default[$seti.readmore; читать дальше &gt^;&gt^;]</a></nobr>}

@editnews[][t]
^if(def $form:dd){$dd[$form:tables.dd]
^dd.menu{
  ^void:sql{DELETE FROM ^dtp[news] WHERE id = '^dd.field.int(0)'}
} ^redirect[$uri^rn[?]]
}{
^editnew0[]
}
@editnew0[]
^use[/login/auto.p]
^if($env:REQUEST_METHOD eq POST && def $form:iog999){
 $exmp[^cnews.menu{$t[$cnews.column]$.$t[$form:$t]}]
 $upd_id[$exmp.id] ^exmp.delete[id]
 $exmp.lastmodified[^now.sql-string[]] $exmp.moderated[yes]
 $exmp.path[^default[$seti.more;$MAIN:uri]?displaynew=$form:displaynew]
 $exmp.content[^taint[sql][^content_prepare[$exmp.content]]]
 ^void:sql{^if(def $upd_id){UPDATE ^dtp[news] SET ^exmp.foreach[k;v]{$k = '^taint[sql][$v]'}[, ] WHERE id = '$upd_id'}{
 INSERT INTO ^dtp[news] (^exmp.foreach[k;v]{$k}[, ]) VALUES (^exmp.foreach[k;v]{'^taint[sql][$v]'}[, ])}}
 ^redirect[$uri?displaynew=$form:displaynew^rn[&]]
 ^if(!def $upd_id){$g(^int:sql{SELECT LAST_INSERT_ID()})^void:sql{UPDATE ^dtp[news] SET path = '$seti.more?displaynew=$g' WHERE id = '$g'}}
}
$exmp[^if(def $form:displaynew){^getnew[^form:displaynew.int(0)]}{
 $.postdate[^now.sql-string[]] $ustar[^date::now[]] ^ustar.roll[month](9)
 $.newsid[$seti.id]
}]
^if(!def $exmp.newsid){$exmp.newsid[default]}
<h4>^if(def $exmp.title){Редактируется;Новая} запись</h4>
<form action="$uri?displaynew=$form:displaynew" method=post name="post">
<input type=hidden name="iog999" value=1>
<input type=hidden name=id value="$exmp.id">
Заголовок новости:<br>
<input type=text name=title size=60 value="$exmp.title"><br>

^if(^hasrig[simple]){
<input type=hidden name="postdate" value="$exmp.postdate">
<input type=hidden name="newsid" value="$exmp.newsid">
}{

Дата новости: <br>
<input type=text name=postdate size=30 value="$exmp.postdate"><br>
Ключевые слова (тэги), через запятую: <br>
<input type=text name=keywords size=30 value="$exmp.keywords">
Раздел:
  $inf[^table::sql{SELECT DISTINCT newsid FROM ^dtp[news]}] ^if(!^inf.locate[newsid;$seti.id]){^inf.append{$seti.id}}
  <select name="newsid">
    ^inf.menu{<option value="$inf.newsid"^if($exmp.newsid eq $inf.newsid){ selected}>$inf.newsid</option>}
  </select><br>
}
Сообщение:<br>
^if(def $seti.visual){
  ^visual[]
}{
  ^unvisual[]
}
^if(!^hasrig[simple]){
<br><input type=checkbox name=autoformat value="no" ^if($exmp.autoformat eq no){checked}>Не делать автоформатирование
}
<br><input type=submit value="Отправить">
</form>

@getnew[id][tmp]
$tmp[^table::sql{SELECT * FROM ^dtp[news] WHERE id = '$id'}]
$result[$tmp.fields]
@is_j[]
^if(def ^cando[$epermission] || (def ^cando[$.news(1)]  && def ^cando[$rpermission])){$result(1)}{$result(0)}

@unvisual[]
^use[htedco.p]
^htedco[content;^taint[as-is][^content_foredit[$exmp.content]];10;50; :more: 		разбивка]
@visual[]
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
} else { document.write('<scr'+'ipt>function editor_generate() { return false; }</scr'+'ipt>'); }
// --></script>

<textarea name="content" cols=60 rows=13>^taint[as-is][^content_foredit[$exmp.content]]</textarea>
<script language="javascript1.2">
editor_generate('content');
</script>
