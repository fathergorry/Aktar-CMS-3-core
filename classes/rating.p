@CLASS
rating

@auto[]
$rrange[^hash::create[]]



$vtype[
$.clinic[^table::create{id	good	bad
1	Дешево	Дорого
2	Эффективное лечение	Неэффективное лечение
3	Радушный персонал	Грубый персонал
4	Комфортные условия	Некомфортные условия}]
$.f[^table::create{id	good	bad
1	По делу	Бесполезно
2	Дружелюбно	Оскорбтельно
3	Особое мнение	Спам}]
$.n[^table::create{id	good	bad
1	Интересно	Неинтересно
2	Информативно	Неинформативно}]
$.user[^table::create{id	good	bad
1	Информативен	Неинформативен
2	Нравится	Раздражает}]
]
$vtype.a[$vtype.f]
$vtype.article[$vtype.n]

#$MAIN:extrahtml[^extrahtml[]]


@box[id;user;count;type][r1;rv]
^if(def $type){^ratewrite[$id;$user;$count;$type]}
^if($rrange.$id is hash){;^addrange[$id]}
$r1[$rrange.$id] $rv(0)
^r1.foreach[k;v]{^rv.inc($v)}
$lastrate($rv)
^rboxhtml[^id.trim[end;0123456789];$id;$rv]

@val[id]
^if(!def $id){$result($lastrate)}

@ratewrite[id;user;count;type]
^connect[$MAIN:scs]{
	$irate[^table::sql{SELECT * FROM ^dtp[rating] WHERE votefor = '$id' AND voter = '$user'}]
	^if(def $irate){
		^if($irate.votetype != $type || $irate.votecount != $count){
		^void:sql{UPDATE ^dtp[rating] SET votetype = '$type', votecount='$count'
		WHERE votefor = '$id' AND voter = '$user'}
		}
	}{
		^void:sql{INSERT IGNORE INTO ^dtp[rating] (votefor, voter, votecount, votetype)
		VALUES('$id', '$user', '$count', '$type')}
	}

}


@addrange[range][emptyrange]
^if($range is string){$range[^table::create{id
$range}]}
$emptyrange[^range.select(^if($rrange.[$range.id] is hash){0;1})]
^if(^emptyrange.count[] > 0){
	^addrange2[$emptyrange]
}

@addrange2[range][rr;r1]
^range.menu{$rrange.[$range.id][^hash::create[]]}
^connect[$MAIN:scs]{
$rr[^table::sql{
	SELECT votefor, votetype, SUM(votecount) AS votecount FROM ^dtp[rating]
	WHERE votefor IN (^range.menu{'$range.id'}[, ])
	GROUP BY votefor, votetype
}]
}
^rr.menu{
	$r1[$rr.votetype]
	$rrange.[$rr.votefor].$r1($rrange.[$rr.votefor].$r1 + $rr.votecount)
} 

@rboxjs[]
<script language="javascript">
^vtype.foreach[k;v]{
rc$k = {^v.menu{$v.id : ["$v.good", "$v.bad"]}[, ]}^;
}
</script>
<style>
.rval{font-weight:bold}
^if($verticalbox){^verticalcss[]}
</style>
@verticalcss[]

.ratingl{display:block;float:left; width:19px; text-align:center; margin-left:-20px; margin-right:1px}
.ratel{display:block; float-left;text-align:center}
.rval{direction:rtl}



@rboxhtml[obj;objId;cnt]
^if(!$rboxjsflag){^call_js[/plugins/jquery.js]^rboxjs[]$rboxjsflag(1)}
<span id="$objId" class="ratingl"><a href="#" onClick="rate('$objId',rc$obj,0,this)" class="ratel">&nbsp^;+&nbsp^;</a>&nbsp^;<span class="rval">$cnt</span>&nbsp^;<a href="#" class="ratel" onclick="rate('$objId',rc$obj,1,this)">&nbsp^;–&nbsp^;</a></span>
