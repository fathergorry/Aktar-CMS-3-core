@version[]
2009-09-23 First

@userdata_settings[][set]
$result[^table::create{param	type	default	descr
}]

@userdata_info[ut;ut][ut;ks;р]
<a href="$form:p?mode=edit">Перейти к редактированию галлереи</a>

@userdata[set]

^userinfo:operate[$set;uid]

@CLASS
userinfo

@operate[s;uid]
$seti[$set] 
^if($MAIN:argument){$userid($MAIN:argument)}{$userid($form:id)}
^if($uid){$userid($uid)}
^use[datawork.p]

^connect[$scs]{
	^if($userid){^showuser[$userid]}{^showall[]}
}

@showall[]
ALL

@showuser[id]
$user0[^datawork::create[users;$.id($id)]]
^user0.form[]
