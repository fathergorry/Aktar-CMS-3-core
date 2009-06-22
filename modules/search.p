
@search_settings[options]
$result[^table::create{param	type	default	descr
lim	string		^lang[518]
res	num	10	^lang[519]
log	bool	yes	^lang[520]
}]

@search_info[set]

@search[set]
<script> $seti[$set]
salert = "^lang[521]";
</script>
<form name=search action="$uri" onSubmit="if (document.search.q.value.length < 4) { alert(salert)^; return false } else { return true }">
<input name="q" type="text" value="$form:q" size="18">
<input type="submit" value="^lang[522]" style="margin-bottom: -4px; margin-top:7px">
<input type=hidden name=slimit value="$set.lim">
</form>
^if(def $form:q){
^connect[$scs]{
^use[adbase2.p]
^memories[$form:q]<p>
^do_search[]<p>
}
^if(def $seti.log){^do_log[]}
}{
  ^if(def ^cando[$.editor(1)] || def ^cando[$epermission]){
    ^show_log[]
  }
}
@show_log[]
$slog[^hashfile::open[/cache/set/searchlog]]
^if(def $seti.log){
<h3>^lang[523]</h3>
 ^slog.foreach[k;v]{  $k - $v<br> }
}{
 ^slog.delete[]
}
@do_log[][slog;sq;sco]
$slog[^hashfile::open[/cache/set/searchlog]]
$sq[$form:q] $sco(^slog.[$sq].int(0)) ^sco.inc[]
^if(def $sq){$slog.$sq[$sco]}
@do_search[]
$fields[^table::create{tab	index	c
structure	head1	menutitle
sections	head2	pagetitle, description
sections	head3	title, keywords
sections	content	content}]$found[] $errors[1] $allr[^hash::create[]]
 ^fields.menu{
 ^if(^allr._count[] < ^seti.res.int(10)){
     ^try{$r[^table::sql{SELECT sect_key, MATCH ($fields.c) AGAINST ('$form:q') AS score
     FROM ^dtp[$fields.tab] WHERE MATCH ($fields.c) AGAINST ('$form:q')
      LIMIT ^seti.res.int(10)}]
     $tmp[^r.hash[sect_key]] ^allr.add[$tmp]
     }{$exception.handled(1) $errors[]}

 }
 }
^if(def $allr){<h3>^lang[524]: ^allr._count[]</h3>
$tmp1[^table::sql{SELECT st.path, st.sect_key, se.pagetitle, se.description, st.visiblity FROM ^dtp[structure] st LEFT JOIN ^dtp[sections] se ON st.sect_key = se.sect_key
WHERE (^allr.foreach[k;v]{st.sect_key = '$k'}[ OR ]) AND st.visiblity != 'no'}]
^tmp1.sort{^if($tmp1.visiblity ne yes){0}{$allr.[$tmp1.sect_key].score}}[desc]<ul>
^tmp1.menu{<li><a href="$tmp1.path">^default[$tmp1.pagetitle;^lang[525]]</a> ^if(def $tmp1.description){<br>$tmp1.description}}[<br>]
</ul>
}{}






@tmp[][в этом варианте какая-то хуйня на мастерхосте. а под 4.01 нормально]
$fields[^table::create{tab	index	c
st	head1	st.menutitle
se	head2	se.pagetitle, se.description
#se	head3	se.title, se.keywords
se	content	se.content}]$found[] $errors[1] $allr[^hash::create[]]
 ^fields.menu{
 ^if(^allr._count[] < ^seti.res.int(10)){
     ^try{$r[^table::sql{SELECT st.path, st.visiblity, se.pagetitle, se.description, MATCH ($fields.c) AGAINST ('$form:q') AS score
     FROM ^dtp[structure] st LEFT JOIN ^dtp[sections] se ON st.sect_key = se.sect_key WHERE MATCH ($fields.c) AGAINST ('$form:q')
     AND st.visiblity NOT LIKE 'no' ^if(def $seti.lim){AND st.path LIKE '${seti.lim}%'} LIMIT ^seti.res.int(10)}]
     $tmp[^r.hash[path]] ^allr.add[$tmp] ^die[searching $fields.c -- ^r.count[] results]
     }{$exception.handled(1) $errors[]}

 }
 }
$allt[^table::create{path	pagetitle	description	score
^allr.foreach[k;v]{$allr.$k.path	$allr.$k.pagetitle	$allr.$k.description	$allr.$k.score}[
]}]
^allt.sort($allt.score)[desc]
^if(def $allt){ $document.pagetitle[Результаты поиска '$form:q']
^allt.menu{<a href="$allt.path">$allt.pagetitle $allt.path</a> <br> $allt.description
}[<p>]
}{^die[Ничего не найдено]}
