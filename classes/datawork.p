@version[]
2009-06-23	file deletion support
2009-05-13	extrahtml, .handle
2009-01-07	Опция вывода скрытых полей
2008-07-21	Поддержка сообщений об ошибках, сгенерированных обработчиком
2008-06-25	Спаны полей

#заменяет устаревший collection.p (обратной совместимости нет!)

@CLASS
datawork

@create[descriptor;condition;fields;set]
^try{^use[/my/dbs/${descriptor}.p]}{$exception.handled(1)}
^if($set is hash){;$set[^hash::create[]]}
$required[^s2h[$set.required]]
$saved_ok_msg[^lang[304]]
^if($MAIN:dw_errors is hash){$MAIN:dw_errors[^hash::create[]]}
^structure[$descriptor;$set.alternate]
^instance_keys.sub[^s2h[$set.exclude]]
$conditions[$condition]
$keylist[^if(def $fields){^instance_keys.intersection[^s2h[$fields]]}{$instance_keys}]
$req2[^hash::create[$required]] ^req2.sub[$keylist] ^required.sub[$req2]
^if(def $condition){
	^createDBExempler[$condition;$set.order;$set.limits;$set.alt_select]
}{
	^if(def $set.from_form){
		^createFormExempler[$set.from_form]
	} 
}
^if(def $set.primary_key){$primary_key[$set.primary_key]}

@structure[whatload;alternate]
$altp[$alternate]$inst_desc[${whatload}$altp]
^if($MAIN:dw_$inst_desc is table){$instance[$MAIN:dw_$inst_desc]}{
$instance[^table::load[/my/dbs/${inst_desc}.txt]]
$MAIN:dw_$inst_desc[$instance]}
$instance_keys[^instance.menu{ $.[$instance.column][$.error(0)] }]
$tbl_name[^dtp[$whatload]]$instance_name[$whatload]
$hUserKeysDef[^db_fld2showinlist[$whatload]]
^if(^instance.locate[key;primary]){$primary_key[$instance.column]}{
	^if(^instance.locate[key;foreign]){$primary_key[$instance.column]}
}

@createFormExempler[prefix][j;dh;result]
^if($prefix eq same){$prefix[]}{^if($prefix eq instance_name){$prefix[${instance_name}_]}}
$dh[^hash::create[]] $onsaves[^instance.menu{$.[$instance.column][$instance.onsave]}]
$formexset{^if(^k.left(4) eq "set_"){$form:tables.$j;$form:$j}}
^keylist.foreach[k;v]{
	$j[${prefix}$k]
	^if($form:$j is file && !def $onsaves.$k){^throw[parser.runtime;Open /my/dbs/${instance_name}.txt and add %your_onsave% handlers to file fields, then define @%your_onsave%[file] in ${instance_name}.p]}
	$dh.$k[^proc[^if(^k.left(4) eq "set_"){$form:tables.$j;$form:$j};$onsaves.$k;$k]] 
}
$datahash[$dh]
$datatable[^table::create{^dh.foreach[k;v]{$k}[	]
^dh.foreach[k;v]{^if($v is file || $v is table){^throw[dw.unhandled;Unhandled '$v.CLASS_NAME' in DW form;Check out onsave handler in /my/dbs/${instance_name}.txt];$v}	}}]
^required.foreach[k;v]{
	^if(!def $dh.$k){
		$tmp(^instance.locate[column;$k])
		^if($instance.form_handler ne file){
			$data_error(1)$keylist.$k.error(1)^die[^lang[470] $instance.comment]
		}
	}
}

@handle[column;data;handler]
^if(^instance.locate[column;$column] && def $instance.$handler){
$result[^proc[$data;$instance.$handler;$column]]
}{$result[$data]}
@proc[d;h;k][tmp] h - handler, d - data, k - key/column
$dp[^^$h^[^$d^]] 
###!!!!!ну хуйня, знаю, но без этого никак
$datawork:d[$d]
###!!!!!!!!!!!! 
$result[$d] ^process[$datawork:CLASS]{^$column_name[$k]^$instance_name[$instance_name]}
^if(def $h){
	^try{
		$result[^process[$datawork:CLASS]{$dp}]
	}{
		^if($exception.comment eq "undefined method"){
			$exception.handled(1)
			^if(def ^cando[] || 1){^die[@$h^[data^;etc^] is undefined. You can define it in /my/dbs/${instance_name}.p]}
		}{
			^if($exception.type eq check){
				$keylist.$k.error(1) $data_error(1)
				$keylist.$k.errtype[check]
				$keylist.$k.comment[$exception.comment]
				$result[^if($d is file){;$d}]
				$exception.handled(1)
			}
		}
	}
}

@createDBExempler[condition;order;limits;alt][tmp]
$datatable[^table::sql{
  SELECT ^if(def $alt){$alt}{^keylist.foreach[k;v]{$k}[, ]} FROM $tbl_name WHERE
  ^if($condition is hash){
    ^condition.foreach[k;v]{$k LIKE '$v'}[ AND ] 
  }{
    $condition
  }
  ^if(def $order){ORDER BY $order}
}[$limits]] 

@returnTable[]
$result[^if(def $datatable){$datatable}{^table::create{^keylist.foreach[k;v]{$k}[	]}}]
#GПридумать, как возвращать таблицу если есть хеш с данными
@returnHash[key;values]
^if(def $datatable){
	^if(^datatable.count[] > 1){
		$rkey[^default[$key;$primary_key]]
		^if(!def $rkey){
			$result[^hash::create[]]^die[Hash key for $tbl_name is not defined!]
		}{
			$result[^datatable.hash[$rkey][$values][$.distinct(1)]]
		}
	}{
		$result[$datatable.fields]
	}
}{
	^if(def $datahash){
		$result[$datahash]
	}{
		$result[$keylist]
	}
}

@save[datahash;must_check;opt_conditions]
^if(def $opt_conditions){$conditions[$opt_conditions]}
^if(!def $datahash){$datahash[^returnHash[]]}
^if(def $must_check){
	$tmp[^hash::create[]]
	^datahash.foreach[k;v]{^if(^instance.locate[column;$k]){
		$tmp.$k[^checkDform[$k;$v]]
	}{}}
}{$tmp[$datahash]}
^if(def $primary_key && $tmp is hash){^tmp.delete[$primary_key]}
^if($conditions is hash){;^if($conditions eq insert){$inserting(1)}}

^if(!$data_error){
	^if($inserting){
		^insert1record[$tmp]
	}{
		^update1record[$tmp;$conditions]
	}
	^if(!def $MAIN:errmsg){^msg[$saved_ok_msg]}
}{^die[^if(def $errmsg){$errmsg}{^lang[471] $tbl_name}]}

@delete_one[cond]
^void:sql{DELETE FROM $tbl_name WHERE $primary_key = '^cond.int(-1)'}

@form[data;div][ic;frm;d;cbox_val;hnd]
^if(!def $div){$div[^hash::create[]]}
^if($div.opt ne inline){^if(!def $div.div){$div.div[<br>]}^if(!def $div.tstyle){$div.tstyle[width:100%]}}
$d[$div.div]
^if(!def $hideForm){
^instance.menu{^if(def $keylist.[$instance.column]){
  $ic[$instance.column] $ii[${instance_name}_$ic] 
  $val[^proc[$datatable.$ic;$instance.onedit;$instance.column]]
  $lg[^if(def $required.$ic){*}^untaint{^lang[$instance.comment]}] 
  ^if($keylist.$ic.errtype eq check || $keylist.$ic.error){$lg[<span class="error">$lg  <b>^untaint{$keylist.$ic.comment}</b></span>]}
<span id="$ii" class="formpiece">
^switch[$instance.form_handler]{
  ^case[text]{${lg}$d<input type="text" class="dw_text $instance.special_handler" name="$ii" style="$div.tstyle" value="$val" /> $d}
  ^case[num]{${lg}$d<input type="text" class="dw_text" name="$ii" size="5" value="$val" /> $d}
  ^case[visualtextarea]{${lg}$d^use[visualeditor.p] ^MAIN:htmlarea[$val;$ii]}
  ^case[textarea]{${lg}$d<textarea name="$ii" style="$div.tstyle" rows="4">$val</textarea>$d}
  ^case[checkbox]{ <input type="checkbox" name="$ii" value="yes"$cbox_val[^s2h[$val]]^if($cbox_val.yes){ checked}^if($cbox_val.disabled){ disabled} />$lg $d}
  ^case[select]{${lg}$d<select name="$ii">$val</select>$d}
  ^case[enum]{$lg $d $tmp1[^enum::parse[$instance.sql_type;;$ii]] ^tmp1.form[$val] $d}
  ^case[special]{$lg $d $val $d}
  ^case[special2]{$val}
  ^case[file]{$lg $d<input type="file" name="$ii"^if(!def $datatable){ disabled} /> ^if(!def $datatable){^default[$div.nofilemsg;загрузка файла будет доступна после отправки формы]}{^if(def $val){<input type="checkbox" name="del_$ii" value="yes">Удалить}} $d $val $d}
  ^case[set]{${lg}${d}^val.replace[^table::create{from	to
_fieldname_	$ii}] $d}
  ^case[DEFAULT]{^if($div.reveal){${lg}$d <em>$val</em> $d}
  <input type="hidden" name="$ii" value="$val" title="$lg"/>}
}</span>
}}
}{$hideForm}
$extrahtml
@show[exclude][locals]
<table border="0" cellspacing="0" cellpadding="2">
^if(def $datatable){^instance.menu{
	<tr class="^if(^math:frac(^instance.line[]/2)){even_row}{odd_row}">
	<td>$instance.comment</td><td>$datatable.[$instance.column]</td>
}}
</table>
@returnPrHash[condition]
^try{$tmp[$instance.$condition]}{$exception.handled(1)$condition[onshow]}
$result[^instance.menu{$k[$instance.column]
	^if(def $keylist.$k){
	$.$k[^proc[$datatable.$k;$instance.$condition;$instance.column]]
	}
}]

@saveMultiple[datatab;key][cm]
$cm[^datatab.columns[]]
^void:sql{UPDATE $tbl_name SET 

WHERE ^parse_cond[$key]}
@parse_cond[cond;tbl]
^if($cond is hash){ ^cond.foreach[k;v]{^if(def $tbl){${tbl}.}$k = '$v'}[ AND ]}{ $cond }

@insert1record[datav]
^void:sql{INSERT INTO $tbl_name
 (^datav.foreach[k;v]{$k}[, ])
 VALUES
 (^datav.foreach[k;v]{'^taint[sql][$v]'}[, ])
#^; LOCK TABLES $tbl_name READ
}
$last_insert(^int:sql{SELECT LAST_INSERT_ID()})
^void:sql{UNLOCK TABLES}
$conditions[$$primary_key($last_insert)]

@update1record[datav;conditions]
^instance.menu{
	^if($instance.form_handler eq file){
		$fdf[del_${instance_name}_$instance.column]
		^if(!def $datav.[$instance.column]){
			^if(def $form:$fdf){
				^try{
					^file:delete[^string:sql{SELECT $instance.column FROM ^dtp[$instance_name] WHERE ^parse_cond[$conditions]}]
				}{^blad[gdeeto]}
			}{^datav.delete[$instance.column]}
		}
	}
}
^void:sql{UPDATE $tbl_name SET ^datav.foreach[k;v]{$k = '^taint[sql][$v]'}[, ] 
WHERE ^parse_cond[$conditions]
}
