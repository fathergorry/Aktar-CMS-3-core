@version[]
2008-08-08	Поддержка форм-обработчиков. Передача параметров через форму
2008-07-19	First

@CLASS
table_editor

@edit[src;opt;permissions]
$dequote[^table::create{from	to
 "	 «
",	»,
".	».
" 	» 
"	}]
^if(def ^cando[$permissions]){^ed2[$src;$opt]}{^die[464]}


@tabloader[src]
$result[^table::load[$src]]

@ed2[src;opt]

$tab[^tabloader[$src]]
<script>
cflag = 0;
function unlockstr(e){
	if(!cflag){
	document.getElementById('lastchb').checked='';
	cflag = 1;
	}
}
</script>
<form action="$uri" method=POST>
$opt.keep
<input type=hidden name=table_edited value="1">
<table>
$u[^tab.columns[]]

#pre-editing user-defined sort
^if(def $form:orderby){
	^tab.sort{$tab.[$form:orderby]}[^if(def $form:reverse)[desc;asc]]
	^msg[^lang[465] $form:orderby ^lang[466]]
}

#adding empty string to the end of edit-ready table
^tab.append{	}
^if(def $form:table_edited){
#get structure of source table to table-3
$tab3[^tab.select(^tab.line[] < 1)]
#prepare table-2 to get data from form
$tab2[^table::create{^u.menu{$u.column	}sortorder}]
^for[i](1;^tab.count[]){
	^if(!def $form:delete$i){
		^tab2.append{^u.menu{$j[${u.column}$i]^form:$j.replace[$dequote]	}$form:sortorder$i}
	}
}
#order by numbers in from's right column
^tab2.sort($tab2.sortorder)
#removing sort column
^tab3.join[$tab2]$tab[$tab3]
^tab3.save[$src] ^msg[467]
#again adding empty string to the end of edit-ready table
^tab.append{	}
}



<tr>^u.menu{<td><b>
	^if($env:REQUEST_METHOD ne POST){
		<a href="^qbuild[orderby=$u.column^if($form:orderby eq $u.column){$sortorder[(+)]&reverse=^if(def $form:reverse){$sortorder[(-)]}{1}}]">}
		$u.column $sortorder $sortorder[]</a>
</td>}<td colspan=2><b>
^if($env:REQUEST_METHOD ne POST){
		<a href="^qbuild[orderby=&reverse=]">}^lang[468]</a></td></tr>


^tab.menu{
<tr>

^u.menu{<td>
$b[^^edit_${u.column}[$tab.[$u.column]^;${u.column}^tab.line[]]]
^try{^process[$MAIN:CLASS]{$b}}{$exception.handled(1)
<input type="text" ^if(^u.column.length[] < 3){size="6"} name="${u.column}^tab.line[]" value="$tab.[$u.column]"^if(^tab.line[] == ^tab.count[]){ onFocus="unlockstr()"}>
}
</td>}
<td><input type=text name="sortorder^tab.line[]" size="4" value="^tab.line[]"></td>
<td><input type=checkbox name="delete^tab.line[]" value="1" ^if(^tab.line[] == ^tab.count[]){checked id="lastchb"}>x</td>

</tr>
}
</table>
<input type="submit" value="Готово">
</form>

