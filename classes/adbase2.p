
@notes----[]
Запрещено переносить разделы с новостями и специальными разделами Адбазы (далее Спецразделы), 
в которых установлена соотв. подпрограмма (Рекламная база и Новости)
Прикрепляемые в форму спецразделов файлы могут быть добавлены только После 
создания описания (т.е. когда в урле есть id=xxx)
Запись может не отображаться если не промодерирована
Не забудьте добавить в избранное ссылки на все разделы с новыми немодерированными записями
Распространенные фамилии нужно дублировать метками, чтобы они более уверенно находились.
Метка выглядит так: <источникданных№записи/> Метки можно посмотреть а каждой записи.
Пример: в новостях пишем "Иванов Иван <person35/> сделал заявление..." 
Метки также нужно ставить, когда упоминаемый находится не в именительном падеже
или если упоминаемый объект не указан в тексте явно. Метки не видны при чтении страницы.
Чтобы разрешить добавление комментариев к какой-либо статье (не новости и не адбазы),
нужно разрешить в ней макросы и прописать внизу [comments]

Структура модификаций (для программиста): 
- основная часть: модуль ad-base.p, он управляет всеми доп.базами, связан с datawork.p
- /custom/adbase.p - общие макросы
- /classes/adb_search.p - поиск по доп.таблицам
- classes/adbase2.p - обработчики для табличных данных (см. доку по datawork)
Особенность адбазных разделов в том, что в них прописывается дизайн для экземпляра, а не страницы.
В общем, это все особенности, остальное в мануале по Актару. 

К уточнению
- Заголовки в 2 и более строк смотрятся некрасиво
- статьи в списке (карта раздела) - нужен красивый вывод. Возможно, давать описание раздела или спец.теги
- параграф предлагаю выравнивать полностью
- выпадающая строка верхнего меню не удобна: сложно довести мышью до края, задевается другой пункт меню и строка заменяется, при другой реализации выпавший список остается висеть и непонятно, к чему он + все равно юзеру непросто его зафиксировать. Варианты: убрать вообще или сделать выпадание вертикальным списком
- функция "ответить на комментарий" скорее всего нереализуема в рамках бюджета, т.к. требует древовидного вывода комментариев, пользовательского скриптования для скрытия/раскрытия текста, а это не оговорено. Кроме того, виртуальный хостинг мастерхоста это не потянет (итак каждый объект требует 2 системных запроса + 1 на себя + 4-7 для поиска упоминаний + 1 для комментариев!!) Большинство сайтов в таких случаях используют обычный, неиерархический список. Если дерево дискуссий все же нужно, предлагаю подождать выхода древовидного форума на общих основаниях. Он будет обратно совместим с вашим приложением.
- Устаревшие тендеры, хоты и т.д. надо как-то удалять. Делать это автоматически или будете вручную?
Ставить значок "завершено"
- Определитесь, в каком формате давать статичные материалы - новости или разделы сайта. Разница в том, что новости идут лентой, а собственно разделы имеют человеко-понятные адреса

фамилии сотрудников не ведут в раздел "Персоны", названия клиентов не ведут в раздел "Рекламодатели", сайты с эксклюзивным размещением не ведут в раздел "интернет проекты"
интернет-проекты согласно ТЗ нет формы для подбора нужного сайта, см. ТЗ
!! скрыть часть полей!

В разделе "предложение" нет ссылки разместить "Горячее предложение" согласно ТЗ, ну и форму оттуда возьмешь
В Глоссарии нет алфавитного указателя
http://aktar-master/useful/links битая ссылка
Поиск и популярные материалы??

#ночные снайперы - не горюй когда узнаешь обо мне ты
#миллион долларов шурша холодно поверь в себя в свою мечту всё будет хорошо

Туду: 
5. Восстановить USERDATA и CFORUM с удаленки!!!!!! А надо?

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
$myt[^table::sql{SELECT ^sr_out[$watchin.adt] AS name, path, id, moderated FROM ^dtp[$watchin.adt] WHERE ^if(def ^cando[editor base-editor]){moderated != 'yes'}{editby = '$MAIN:userid'}   }]
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
^connect[$scs]{$an[^table::sql{SELECT CONCAT(^sr_out[$tab]) AS name, path 
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
		^case[structure]{menutitle}
		^case[news]{title}
		^case[adtab]{
			^sr_out[$sTable]
		}
	} AS name, '$frm.score' AS score
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

@tags[data;sm]
$a[^table::sql{SELECT DISTINCT $data.column AS name, COUNT($data.column) AS score
FROM ^dtp[$data.table] WHERE moderated = 'yes' GROUP BY $data.column ORDER BY score DESC LIMIT 45}]
^tagcloud[$a;$data.url?filter=field&field=$data.column&value;, 
]

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
