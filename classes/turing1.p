
#parser 3.1.2 CAPTCHA image class by George Andriyanov (http://aktar.sibarit.ru, george@sibarit.ru)

@CLASS
captcha_pic

@auto[]
#установите серверный ключ
$serverkey[Злобный хакер прячет тело ^default[$globals.site_admin;$env:SERVER_ADMIN] жирное в утесах]

#установите пути к картинкам. Сами картинки менять не надо.
$background[/login/img/noise150.gif]
$source_font[/login/img/digitfont25_^math:random(2).gif]
$processed_font[/login/img/digitfont25_processed.gif]

@create[requested_info;imgsrc]
#создадим объект - картинку со шрифтом
$pic[^image::load[$background]]
^pic.font[0123456789;$processed_font](0;25)

#пользовательский ключ
^if(!def $cookie:captchaid){
	$cookie:captchaid[$.value[^rnd(100000)]$.expires[session]]
}

#серверный хеш создается по пользовательскому и серверному ключам, и идентификатору запрашиваемой информации(например, имени файла)
$key[^math:md5[$requested_info + $serverkey + $cookie:captchaid]]
#затем обрубается до первых 1-5 цифр
$key[^key.left(4)]
$key[0x$key] 
$key($key) ^if($key > 30000){ $key[$key] $key(^key.left(4))}
$key_str[$key] 

#часть операций требует относительно много ресурсов, но не требует постоянного выполнения
^if(^rnd(30) == 1){^morph[]}


@dflt[a;b]
$result[^if(def $a){$a;$b}]


#возвращает картинку с цифрами
@image[save][str;x;tmp;y]
$tmp(0)
^for[i](0;^key_str.length[]){
  $tmp($tmp + ^rnd(9)) $y(^rnd(20))
  $x($tmp + $i * 25)
  ^pic.text($x;$y)[^key_str.mid($i;1)] 
  ^if($y < 6){^add($x;32 + ^rnd(3))}
  ^if($y > 14){^add($x;-13 - ^rnd(3))}
}
#$pic.line-style[*** ]^for[i](1;9){^pic.line(^rnd(150);^rnd(40);^rnd(150);^rnd(40);^rnd(0xffffff))} фигня, но можно включить
^if(!def $save){
	$result[$pic]
}{ 
	$gif[^pic.gif[]]
	^gif.save[binary;/cache/captcha/${cookie:captchaid}.gif]
	$result[<img src="/cache/captcha/${cookie:captchaid}.gif" />]
}
#добавим обрезки случайных цифр сверху и снизу
@add[x;y][text]
^pic.text($x;$y)[^rnd(10)]

#удаляет пользовательский ключ
@clear_userkey[]
^try{^file:delete[/cache/captcha/${cookie:captchaid}.gif]}{^blad[gdeeto]}
$cookie:captchaid[]

@rnd[num]
$result(^math:random($num))

@morph[][img;img1;bgr]
$new_color(0x006060 + ^rnd(100) - 50)

$img1[^image::load[$source_font]]

#немного продырявим цифры
^for[i](1;200){
	^img1.pixel(^rnd(25);^rnd(240);0xffffff)
}

#зальем цифры новым цветом. Хотя, B/W и вся недолга...
$nodes[^table::create{x	y
6	16
10	36
17	55
14	83
13	104
8	129
8	155
11	171
8	203
15	228}]
^nodes.menu{
#нельзя, чтобы заливка вышла за пределы цифры
	^if(^img1.pixel($nodes.x;$nodes.y) < 0xffffff){
		^img1.fill($nodes.x;$nodes.y;$new_color)
	}
}
#сохраним обработанный шрифт
$img2[^img1.gif[]]
^img2.save[binary;$processed_font]

#теперь - фон. 
$bgr[^image::create(150;40)]
^for[1](1;2200){
	^bgr.pixel(^rnd(150);^rnd(40);$new_color + ^rnd(1))
}
$bgr[^bgr.gif[]]
^bgr.save[binary;$background]
