@version[]
2008-09-21	Foodzy

@swapcontent_settings[opt]
$result[^table::create{param	type	default	descr
path	string		Раздел для подстановки}]

@swapcontent_info[set]
Эта подпрограмма используется для того, чтобы поместить в данный раздел содержимое дугого раздела.
Если оставить пустым раздел для подстановки, будет использоваться подстановка по умолчанию для данного сайта.
Например, предопределенные дочерние разделы, ассоциированные с регионом посетителя.

@swapcontent[set]

^if(def ^cando[editor $epermission]){
^msg[Эта страница использует подкачку. Информация, видимая редактором, может отличаться от того, что видит пользователь.]
}

@swap_path[base][url]
^connect[$scs]{
$url[${base}$cookie:fdzcity]
^if(!def $form:p && !def $form:editcontent && 
def ^string:sql{SELECT path FROM ^dtp[structure] WHERE path = '$url' LIMIT 1}[$.default{}]){
	$result[$url]
}{
	$result[$base]
}

}
