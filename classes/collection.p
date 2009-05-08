@version[]
2009-01-01	хуй знает какая
@CLASS
collection
#old 
@create[whatload;alternate]
$instance[^table::load[/my/dbs/${whatload}${alternate}.txt]]
$tbl_name[^dtp[$whatload]]
^if(^instance.locate[key;primary]){$used_key[$instance.column]}{
 ^if(^instance.locate[key;foreign]){$used_key[$instance.column]}
}

@createInstance[fields;DBid][fd;th;tmp]
$th[^hash::create[]]
^if(def $fields){$fd[^s2h[$fields]]}{$fd[^instance.menu{$.[$instance.column](1)}]}
^if(def $DBid && def $used_key){
  ^connect[$MAIN:scs]{$tmp[^table::sql{SELECT * FROM $tbl_name WHERE $used_key = '$DBid'}]}
^fd.foreach[k;v]{
 ^if(def ^instance.locate[column;$k]){
   $th.$k[$tmp.$k]
 }
}
}
^fd.foreach[k;v]{
 ^if(def ^instance.locate[column;$k]){
   ^if(def $form:$k){
     $th.$k[$form:$k]
   }
 }
}
$result[$th]

@updateInstance[hh;id]
^connect[$MAIN:scs]{^void:sql{
UPDATE $tbl_name SET
^hh.foreach[k;v]{
 $k = '^taint[sql][$v]'
}[, ] WHERE $used_key = '$id'
}}
@getOne[key;value]
^connect[$MAIN:scs]{
$exempler[^table::sql{SELECT * FROM $tbl_name WHERE ($key = '^if(def $value){$value}{884939}') LIMIT 1}]
}
@insertInstance[hh;redirect][lid]
^connect[$MAIN:scs]{^void:sql{
INSERT INTO $tbl_name (^hh.foreach[k;v]{$k}[, ]) VALUES
(^hh.foreach[k;v]{'^taint[sql][$v]'}[, ])
}
$lid[^int:sql{SELECT LAST_INSERT_ID()}]
}
$result($lid) 

@editOne[key;value;fieldset][c]
$allowed_fields[^s2h[text select textarea enum]]
^if(def $fieldset){$fieldset[
$fieldset]}{
$fieldset[^instance.menu{^if(def $allowed_fields.[$instance.form_handler]){
$instance.column}}]
}
$fieldList[^table::create{field^untaint{$fieldset}}]
$fieldHash[^fieldList.hash[field]]
^update[$key;$value]
^if(def $primary_key){^getOne[$primary_key;$last_insert_id]}{
  ^if(def $value){^getOne[$key;$value]}
}
<input type=hidden name="$tbl_name" value="^if(def $value){$value}{new}">
$over_design[${tbl_name}_design]
^if($MAIN:$over_design is junction){
 ^MAIN:$over_design[]
}{
 ^defaultDesign[]
}

@listItems[keyHandler;keyDisplay;param;format]
^connect[$MAIN:scs]{
$list[^table::sql{SELECT $keyHandler, $keyDisplay FROM $tbl_name}]
^list.menu{<a href="?^if(def $param){$param}{edit}=$list.$keyHandler">$list.$keyDisplay _<a> ^if(def $format){$format}{<br>} }
}
@delete[key;value]
^void:sql[DELETE FROM $tbl_name WHERE $key = '$value']
@update[key;value]
^if(def $form:$tbl_name){^connect[$MAIN:scs]{
  ^if($form:$tbl_name eq new){^insertEmpty[$key;$value]}
  ^updateRecord[$key;$value]
}}
@updateRecord[key;value][fh]
^void:sql{UPDATE $tbl_name SET
^fieldHash.foreach[k;v]{$fh[${tbl_name}_$k]$k = '$form:$fh'}[, ]
  WHERE ^if(def $primary_key){$primary_key}{$key} = '^if(def $last_insert_id){$last_insert_id}{$value}' }
@insertEmpty[key;value][last_insert]
^void:sql{INSERT INTO $tbl_name ($key) VALUES ('^if(def $value){$value}')}
^if(^instance.locate[key;primary]){$primary_key[$instance.column] $last_insert_id[^string:sql{SELECT LAST_INSERT_ID()}]}
@defaultDesign[]
^instance.menu{
	$i_column[$instance.column]
	^if(def $fieldHash.$i_column){^formElement[]}{}
}
@formElement[][text_value]
^switch[$instance.form_handler]{
  $text_value[<input type=text name="${tbl_name}_${i_column}" value="$exempler.$i_column">]
  ^case[text]{^lang[$instance.comment] <br> $text_value <br>}
  ^case[num]{^lang[$instance.comment] <br> $text_value <br>}
  ^case[visualtextarea]{^lang[$instance.comment] <br> ^use[/classes/visualeditor.p] ^MAIN:htmlarea[$exempler.$i_column;${tbl_name}_${i_column}]}
  ^case[select]{^lang[$instance.comment] <br> $text_value <br>}
  ^case[textarea]{^lang[$instance.comment] <br><textarea name="${tbl_name}_${i_column}">$exempler.$i_column</textarea><br>}
  ^case[checkbox]{ <input type="checkbox" name="${tbl_name}_${i_column}" value="yes"^if($exempler.$i_column eq yes){ checked}>^MAIN:lang[$instance.comment] <br>}
  ^case[hidden]{}
  ^case[enum]{^lang[$instance.comment] <br> $tmp1[^enum::parse[$instance.sql_type;;${tbl_name}_${i_column}]] ^tmp1.form[$exempler.$i_column] <br>}
  ^case[DEFAULT]{<input type=hidden name="${tbl_name}_${i_column}" value="$exempler.$i_column"><br>}
}
