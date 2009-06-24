@version[]
2008-11-12	Поддержка многостолбцовых индексов
2009-02-06	кусочное восстановление таблиц
@CLASS
dbobj

@USE
collection.p

@BASE
collection

@create[whatload]
$instance[^table::load[/my/dbs/${whatload}.txt]]
$tbl_name[^dtp[$whatload]]

@update_table[simulate][my_fields;current_column;same_teble]
$fields[^hash::sql{SHOW FIELDS FROM $tbl_name }]
$my_fields[^hash::create[]]
^void:sql{ALTER TABLE $tbl_name
^instance.menu{
  $current_column[$instance.column]
  ^if($fields.$current_column){
     CHANGE $current_column $current_column ^untaint{$instance.sql_type}
  }{
     ADD $current_column ^untaint{$instance.sql_type}
  }
  $my_fields.$current_column[]
}[ , ]
 ^update_keys[]
}
^fields.sub[$my_fields]
^if($fields){^void:sql{ALTER TABLE $tbl_name
  ^fields.foreach[key;value]{DROP COLUMN $key }[, ]
}}{}
@create_table[]
^void:sql{DROP TABLE IF EXISTS $tbl_name }
^void:sql{CREATE TABLE $tbl_name (
  ^instance.menu{
   $instance.column ^untaint{$instance.sql_type}
  }[, ]
  ^set_keys[]
)}

@keylistgen[][stkeys;ik;keyflag]
$stkeys[^hash::create[]]
^instance.menu{$ik[$instance.key]
	^if(def $ik){
		^if($stkeys.$ik is table){;
			$stkeys.$ik[^table::create{key}]
		}
		^stkeys.$ik.append{$instance.column}
	}
}
^stkeys.delete[fulltext]
$result[$stkeys]

@set_keys[][ks]
$ks[^keylistgen[]]
^ks.foreach[k;v]{
	^switch[$k]{
		^case[key]{
			^v.menu{, KEY ($v.key)}
		}
		^case[primary]{
			, PRIMARY KEY (^v.menu{$v.key}[, ])
		}
		^case[DEFAULT]{
			, KEY (^v.menu{$v.key}[, ])
		}
	}
}
@update_keys[][column]
$ks[^keylistgen[]]
, DROP PRIMARY KEY 
^ks.foreach[k;v]{
	^switch[$k]{
		^case[key]{
			^v.menu{, ADD KEY ($v.key)}
		}
		^case[primary]{
			, ADD PRIMARY KEY (^v.menu{$v.key}[, ])
		}
		^case[DEFAULT]{
			, ADD KEY (^v.menu{$v.key}[, ])
		}
	}
}

@repair[withTable;keytor;keyble] #table1, key of table1, key of instance table
^connect[$MAIN:scs]{
$reparator[^hash::sql{SELECT DISTINCT $keytor as keyr FROM ^dtp[$withTable] }]
$reparable[^hash::sql{SELECT DISTINCT $keyble as keyr FROM $tbl_name }]
$commons[^reparable.intersection[$reparator]]
^reparator.sub[$commons]
^reparable.sub[$commons]
^if($reparator){^reparator.foreach[key;value]{^void:sql{DELETE FROM ^dtp[$withTable] WHERE $keytor = '$key'}}}{}
^if($reparable){^reparable.foreach[key;value]{^void:sql{DELETE FROM $tbl_name WHERE $keyble = '$key'}}}{}
}

@backup[path][bkp]
^connect[$MAIN:scs]{
$bkp[^table::sql{SELECT * FROM $tbl_name }]
^bkp.save[$path;
  $.encloser[^#02] 
#whatever...
]}


@fortablepart[partname;src;each;code][locals]
$j(1)$t0[^src.select(false)]
^while(true){
	$caller.$partname[^table::create[$t0]]
	^caller.$partname.join[$src;$.offset(($j - 1)*$each)$.limit($each)]
	^j.inc(1)
	^if(^caller.$partname.count[] == 0){^break[]}{
		$code
	}
}

@restore[path][restore]
$t_restore[^table::load[$path;$.encloser[^#02]]]
^connect[$MAIN:scs]{
^create_table[] $restore_count(0)
$tmp[^t_restore.columns[]] $eachpart(^math:ceiling(6000/^tmp.count[]))
	^fortablepart[t1;$t_restore]($eachpart){
		^restore2[$t1]
		^memory:compact[]
		^restore_count.inc(1)
	}
}

@restore2[t_restore]
 ^t_restore.menu{ 
   ^void:sql{INSERT INTO $tbl_name (^instance.menu{$instance.column}[, ])
   VALUES ( ^instance.menu{'^try{$t_restore.[$instance.column]}{$exception.handled(1)}'}[, ] )
   }
 }
@CreateDBImage[ovr][tmp]
^connect[$MAIN:scs]{
	^if($ovr eq unsafe){^create_table[]}{
	  $tmp[^hash::sql{SHOW TABLES}]
	  ^if($tmp.$tbl_name){^update_table[]}{^create_table[]}
	}
}

