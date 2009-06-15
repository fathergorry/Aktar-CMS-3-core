@version[]
2009-06-15	RSS
2008-03-19	Картировка - в модуле + %this% + minor bugs

@sectionmap_settings[][set]
$result[^table::create{param	type	default	descr
path	string	this	Картировать, начиная с раздела
limit	num	5	Уровень заглубления
bydate	bool	yes	Сортировать по дате
showpic	bool	yes	Показывать картинки
markempty	bool	yes	Отмечать непустые разделы}]


@sectionmap_info[set][ut;ks;р]
$set[^set.menu{$.[$set.param][$set.value]}]
^if($set.path eq this){$set.path[$uri]}
$tmp[^sitemap[$set]] <b>^sitemap.count[]</b> разделов будут отображаться
@sectionmap[set]
^if(!def $set.bydate && def ^cando[editor]){<p><a href="/login/groupedit.htm?grpfield=s.sect_order&grplimit=$uri&grpnum=2">Изменить очередность разделов</a></p>}
^connect[$scs]{
^sitemap[$set]
}


@sitemap[set;d][eye;pic]
#Установки настроек
^if($set is hash){}{$set[^hash::create[]]}
^if($set.path eq this){$set.path[$MAIN:uri]}
^if(!def $set.path){$set.path[$uri]} $set.path[^set.path.trim[end;/]/]

#Получаем карту
$sitemap[^table::sql{SELECT s.path, s.sect_order, s.sect_key, 
^if(def $set.bydate){1 AS level}{s.level}, 
s.menutitle, se.pagetitle, se.description, se.picture, 
^if(def $form:export){s.created, s.modified, se.title, }
s.rpermission, s.epermission, s.visiblity, s.module, s.modified, 
#Проверяем наличие контента
^if(def $globals.IUseFiles && !def $set.markempty){
	'y' AS exist
	}{
	CASE se.content WHEN '' THEN '' ELSE 'y' END AS exist
}
^combine_s_se[] WHERE s.path LIKE '$set.path%' 
#Ограничиваем объем выборки по заглублению
^if(def $set.limit){AND level <= '^eval(^pathlevel[$set.path] + ^set.limit.int(2))'} 
#Нельзя выдавать корень, есл смотрим с корня
^if($set.path eq "/"){AND s.path != '/'}
#Скрытые разделы, если есть права
^if(!def ^cando[$erpermission] && !def ^cando[$.editor(1)]){
	^if(!def $globals.includeNoMenu){
		AND s.visiblity LIKE 'yes'
	}{
		AND s.visiblity NOT LIKE 'no'
	}
	}
#Если выводим по дате, то структура теряется
ORDER BY ^if(def $set.bydate){s.created DESC}{s.path}}]
^if($form:export eq rss){
	$response:body[^sitemap_rss[$sitemap]]
}{
^if(!def $set.bydate){$sitemap[^tree_sort[$sitemap]]}
^if($sitemap_design is junction){
	^sitemap_design[$sitemap]
}{
	^def_sitemap_design[$sitemap]
}}
<a href="$uri?export=rss"><span style="background-color:#ff6600^;font-size:9px^;text-decoration:none^;color:#FFFFFF^;padding:2px^;letter-spacing:1px">rss</span></a>

@def_sitemap_design[sitemap]
 $eye{^if($sitemap.visiblity ne yes){<img src="/login/img/eye.gif" align=baseline title="Закрыто">}}
 $pic{^if(def $set.showpic && def $sitemap.picture){^if(-f "/my/img/node_pics/$sitemap.picture"){<a href="$sitemap.path"><img src="/my/img/node_pics/$sitemap.picture" border="0" /></a><br>}}}
 ^sitemap.menu{$otstup(^eval($sitemap.level - ^pathlevel[$set.path] -1))
 <div style="padding-left:^eval($otstup * 20)px^; padding-top:8px">$eye<a href="$sitemap.path">
 ^if(def $sitemap.exist){<b>}
 ^default[$sitemap.pagetitle;$sitemap.menutitle] ^if(def ^cando[]){$sitemap.modified} </a></b><br>$pic ^if(def $sitemap.description){$sitemap.description <a href="$sitemap.path">&gt^;&gt^;</a>}
 </b></div>
 }
@sitemap_rss[sitemap]
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
$response:charset[UTF-8]
$response:content-type[
        $.value[application/rss+xml]
        $.charset[$response:charset]
]
^try{^sitemap.sort(^date::create[$sitemap.modified])[desc]}{^blad[]}
<channel>
    <title>^taint[xml][^default[$document.pagetitle;$document.menutitle] - список обновлений раздела]</title>
    <link>http://${env:SERVER_NAME}$uri</link>
    <description>^taint[xml][^default[$document.description;$document.title]]</description>
    <language>ru</language>
    <pubDate>^now.gmt-string[]</pubDate>
 $LBD[^date::create[^default[$sitemap.modified;$document.modified]]]
    <lastBuildDate>^LBD.gmt-string[]</lastBuildDate>
    <docs>http://blogs.law.harvard.edu/tech/rss</docs>
    <generator>Aktar CMS</generator>
    <managingEditor>$globals.site_admin</managingEditor>
    <webMaster>$globals.site_admin</webMaster>
    ^sitemap.menu{
    <item>
      <title>^taint[xml][$sitemap.pagetitle]</title>
      <link>http://${env:SERVER_NAME}$sitemap.path</link>
      <description>^taint[xml][^default[$sitemap.description;$sitemap.title]<br> Обновлено ^ufdate[$sitemap.modified]] </description>
      $PD[^date::create[$sitemap.modified]]
      <pubDate>^PD.gmt-string[]</pubDate>
      <guid>http://${env:SERVER_NAME}$sitemap.path</guid>
    </item>
    }
</channel>
</rss>
