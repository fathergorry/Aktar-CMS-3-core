@version[]
2009-03-14	v3
#Assign compopt data like this:
#Category1==1,2,3,4,5,6,6,7,default=3,,Category2==az,buki,corova

@CLASS
compopt
@create[str;id;ta;ne;ta2;ne2]
$classID[$id]
 $tab[^default[$ta;==]]
 $new[^default[$ne;,,]]
$tab2[^default[$ta2;=]]
$new2[^default[$ne2;,]]
$exmp[^expand[$str;$tab;$new]]
$hexmp[^exmp.menu{
	$b[^expand[$exmp.value;$tab2;$new2]]
	^if(^b.locate[param;default]){
		$ky[${exmp.param}def]
		$.$ky[$b.value]
		$b[^b.select($b.param ne "default")]
	}
	$.[$exmp.param][$b]
}]
@2selform[sValue;opt]
$tVa[^expand[^default[$sValue;^catchForm[]];$tab;$new]]
^exmp.menu{
	$exmp.param<select class="compopt" name="cf^exmp.line[]$classID">
	$t[$hexmp.[$exmp.param]]
	$td[${exmp.param}def]
	^if(^tVa.locate[param;$exmp.param] && def $tVa.value){
		$td[$tVa.value]
	}{
		$td[$hexmp.$td]
	}
	^t.menu{
		<option value="$t.param"^if($t.param eq $td){ selected}>^default[$t.value;$t.param]</option>
	}
	</select>
}
@changeID[newId]
$classID[$newId]

@catchForm[]
$result[^exmp.menu{${exmp.param}${tab}^fval[^exmp.line[]]}[$new]]
@fval[param][b]
$b[cf${param}$classID]
$result[$form:$b]


