@CLASS
modinfo

@create[mod]
$modtab[^try{^table::load[/my/deriv/modinfo/${mod}.txt]^if(^math:random(200)==3){^trow[1;1]}}{$exception.handled(1)^sql_modtab[$mod]}]

@sql_modtab[mod]
^connect[$MAIN:scs]{
$hd[^table::sql{SELECT s.path, s.module, se.module_settings ^combine_s_se[] WHERE s.module = '$mod'}]
^hd.save[/my/deriv/modinfo/${mod}.txt]
}
$result[$hd]

@focus[param;value]
$focustab[^modtab.select(^if(!$fflg && ^modtab.module_settings.pos[$param==$value] >= 0){$fflg(1)1;0})]
$focdata[^expand[$focustab.module_settings]]
$fflg(0)
@returnpath[]
^if($focustab is table){$result[$focustab.path]}{$result[/]^die[Call ^^.focus[] first!]}

@returnval[param]
$tmp[^focdata.locate[param;$param]]$result[$focdata.value]
