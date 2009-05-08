#!require shop_admin.p, forms_shop.p, shop.cfg, user's *.shop.cfg


############################################
#PLUGIN LAYER
############################################

@shop_settings[options]
$result[^table::create{param	type	default	descr
id	num	1	Номер магазина
#minsum	num	0	Минимальная сума заказа
all	bool	yes	Отображать товары из всех магазинов (сделать магазин главным)
freq	option	price itemname	Необходимые поля товара
admin	string		E-mail администратора
rpp	num	50	Товаров на странице
#item_output	string		<span style="cursor:help" title="Создайте макрос, например item.cfg. В нем напишите что-то подобное: <h1>^[var^;itemname^]</h1> Цена: ^[var^;price^]руб <br>Вес: ^[var^;weight^]кг">Макрос для вывода</span> товара
noreg	bool	yes	Можно совершать заказы без регистрации
addmod	string	$g[^file:list[/modules/;\.shop.cfg^$]]$g[^g.name.trim[end;.shop.cfg]]$g	^lang[Ваш модуль (например,] $g)}]

@shop_info[set][tmp;tmpn]
Editor's permission: seller<br>
Client manager's permission: manager<br>
^if(def $form:expanded){^shop_expanded_info[]}{<a href="update.htm?p=$form:p&expanded=true^rn[&]">показать список магазинов</a>}<br>
СОХРАНИТЕ ЭТУ СТРАНИЦУ<br>

@shop_expanded_info[]
$ashop_id[^table::sql{SELECT DISTINCT shop_id FROM ^dtp[shop]}] $bsh[^hash::create[]]
$bshops[^table::sql{SELECT s.menutitle, s.path, se.module_settings ^combine_s_se[] WHERE s.module LIKE 'shop.p'}]
<br>Номера магазинов с товарами:<br>
^bshops.menu{ $tmp[^expand[$bshops.module_settings]] ^if(^tmp.locate[param;id]){
	^if(^ashop_id.locate[shop_id;$tmp.value]){
	$tmp.value - <a href="$bshops.path">$bshops.menutitle</a><br>
	}
}}


@shop[s][g]
$seti[$s]
^use[/modules/shop.cfg]
^try{
^if(!def $seti.addmod){
   $g[^file:list[/modules/;\.shop.cfg^$]]
   ^use[/modules/$g.name]
}{
  ^use[/modules/${seti.addmod}.shop.cfg]
}}{$exception.handled(1)}

$required[^s2h[$seti.freq]]
^if($seti is hash){}{$seti[^hash::create[]]}
^if(^seti.id.int(0) < 1){$seti.id(1)}
^if(def $form:msg){^msg[^lang[$form:msg]]}
$shptt[^table::load[/classes/shop.txt]] $shpt[^shptt.hash[column]] ^shpt.delete[item_id] ^shpt.delete[shop_id]
^if(def $form:action){$action[$form:a]}
^no_reg_condition[]
^connect[$scs]{
^switch[$form:a]{
^case[item]{^showitem0[]}
^case[cart]{^preparecart[]}
^case[delete_archive]{^if(^is_manager[]){^use[/modules/shop_admin.p]^delete_archive[];^die[Залупу тебе на воротник.]^showall0[]}}
^case[edit_multiple]{^if(^is_seller[]){^use[/modules/shop_admin.p]^edit_multiple[];^showall0[]}}
^case[edit_status]{^if(^is_manager[]){^use[/modules/shop_admin.p]^admin_reqlist[]}}
^case[DEFAULT]{^showall0[]}
}}
^if(^is_manager[]){<br><a href="$uri?a=delete_archive">^lang[удалить архив заказов]</a> <a href="$uri?a=edit_status">редактировать заказы</a>}

############################################
#BASIC USER LAYER
############################################
@blank_output[text]
$response:body[<html> $text </html>]

#start cart output
@display_cart0[]
^if(!def $user.name && !^is_manager[]){$nosave(1)}

<form action="$uri?a=cart^rn[&]" method=POST>
^if(^is_manager[]){
	<a href="^link2cart[]&payment_form=ship&requesting=наклейка на посылку">ship</a>
	<a href="^link2cart[]&payment_form=opis&requesting=опись вложения">опись</a>
}
<input type=hidden name=mode value=refresh>
^keepvalue[workas cartid]
^if(def $form:payment_form){
	^use[/modules/forms_shop.cfg]
	^try{
		^forms_select[]
	}{
		$exception.handled(0)^die[^sl[31;no such form]]
		^display_cart[]
	}
}{
	^if(def $form:done){
		^send_request0[]
	}{
		^display_cart[]
	}
}
</form>

#start items list output
@showall0[]
^if($form:a eq alphabetic){
	$letters[^expand[^try{^alphabet[]}{$exception.handled(1)A B C D E F G H I J K L M N O P Q R S T U V W X Y Z};; ]]
	$pp[^pagination::create[9999;9999]]
}{
   $r(^int:sql{SELECT COUNT(item_id) FROM ^dtp[shop]
   WHERE ^if(def $seti.all){1}{shop_id = '$seti.id'}
   ^if(!^is_seller[]){AND visible = 'yes'}})
   $pp[^pagination::create[$r;^seti.rpp.int(10)]]
}
$items[^table::sql{
   SELECT *
   FROM ^dtp[shop] WHERE ^if(def $seti.all){1}{shop_id = '$seti.id'}
   ^if(!^is_seller[]){AND visible = 'yes'}
   ^if(def $form:letter){AND itemname LIKE '${form:letter}%'}
   ^if(def $form:q){AND itemname LIKE '%${form:q}%'}
   ^if(def $form:ids){$ids[^s2h[$form:ids]]AND (^ids.foreach[k;v]{item_id = '$k'}[ OR ])}
   ORDER BY itemname ASC}[^pp.q[limits]]
] 
<form action="$uri?a=cart&mode=add^rn[&]" method=post class="shop_form">
	^if(^is_manager[]){^keepvalue[workas cartid]}
	^showall[]
</form>



@sql_get_item[id]
$item[^table::sql{SELECT * FROM ^dtp[shop] WHERE item_id = '^itemid.int(-1)'}]
^if(def $item){$item[$item.fields]}{$item[^hash::create[]]}
@showitem0[]
$itemid[^default[$form:id;$form:edit]] ^sql_get_item[]
^if(!def $item && $form:edit ne new){^die[^sl[11;Not found]]}
^if(def $item){
 ^if(def $form:id || !def ^is_seller[]){^showitem1[]}{^edit_item0[]}
}{^if($form:edit eq new && def ^is_seller[]){^edit_item0[]}{$response:status[404] ^sl[11;Not found]<p>}}
@showitem1[]
$document.pagetitle[$item.itemname] $document.title[$item.itemname - $document.title]
$shop_before_item
^if($shop_item_design is junction){^shop_item_design[]}{^showitem[]}
$shop_after_item

@edit_item0[]
^use[/modules/shop_admin.p]^edit_item[]


############################################
#DATA LAYER
############################################
@preparecart[]
^if(def $user.id){
	$workas($user.id)
}{
	^if(def $seti.noreg && ^cookie:tempuserid.int[] >= 5000000){
		$workas(^cookie:tempuserid.int[])
	}
}
^if(^is_manager[] && def $form:workas){$workas($form:workas)}
^if($workas){
	^getcart[]
	^totals[]
	^business_layer[]
	^savecart[]
	^display_cart0[]
}{^die[^sl[18;not logged in]]}

@getcart[][tm]
$cart[^table::sql{
SELECT * FROM ^dtp[cart] WHERE userid = '^default[$change_cart_owner;$workas]'
^if(^form:cartid.int(0)){
   AND cart_id = '^form:cartid.int(0)'
   ^if(!^is_manager[]){
      AND (status = 'edit' OR status = 'done' OR status = 'sent_not_paid')
   }
}{
   AND status = 'edit'
}
ORDER BY cartdate ASC LIMIT 1}]
$cart[$cart.fields]
^if($change_cart_owner){$cart.userid($user.id)}
$cart_error[^hash::create[]]

^get_cc_from_db[]
^get_cc_from_forms[]
^savecc[getcart]
^get_cc_from_db[]


@get_cc_from_db[]
$ifds[^s2h[^try{^addfld2cart[]}{^sorry[!!@]} item_id shop_id visible itemname price url instock min_qty min_sum weight nds]]
^if($cart.cart_id > 0){
$cc[^table::sql{SELECT c.* ^ifds.foreach[k;v]{, t.$k}
 FROM ^dtp[cartcount] c LEFT JOIN ^dtp[shop] t ON c.item_id = t.item_id WHERE cart_id = '^cart.cart_id.int(0)' AND t.visible = 'yes'}]
$cc[^cc.hash[item_id][$.distinct(1)]]
^cc.foreach[k;v]{$cc.$k.qty(^cc.$k.qty.int[])}
}{$cc[^hash::create[]]}


@get_cc_from_forms[][utovars;u]
^if($form:mode eq add){
	$utovars[$form:tables.u] ^if($utovars is table){;$utovars[^table::create{field}]^die[^sl[35;no item!]]}
	^utovars.menu{
		$u[$utovars.field]
		^if(def $form:u$u || ^utovars.count[] <=1){
			^if($cc.$u is hash){
				^cc.$u.qty.inc(^form:u$u.int(0))
			}{
				$cc.$u[$.cart_id[$cart.cart_id] $.qty(^form:u$u.int(1))] $must_create_cart(1)
			}
		}
	}
}
^if($cart.cart_id < 1 && $must_create_cart){^savecart[]}
^if($form:mode eq refresh){
	^cc.foreach[k;v]{
		$cc.$k.qty(^form:u$k.int(0))
	}
	^if(def $form:quickreq){
		^quickadd[^s2h[$form:quickreq]]
	}
$cart.payment_type[$form:payment_type]
}

@cleancc[][tm]
$tm[^hash::create[]]
^cc.foreach[k;v]{^if(!def $cc.$k.itemname || ^cc.$k.qty.int(0) <= 0){$tm.$k(1)}$cc.$k.qty(^cc.$k.qty.int(0))}
^tm.foreach[k;v]{^cc.delete[$k]}

@savecart[][cartid;ut]
$cart.cartdate[^now.sql-string[]] $ut[$form:tables.u] ^if($ut is table){;$ut[^table::create{r	t}]}
#^if(def $form:mng_discount && ^is_manager[] && ^form:mng_discount.int[] != $discount){	$cart.sid(^form:mng_discount.int[])}
^if(^cart.cart_id.int(0) < 1 && def $cc){
	^void:sql{INSERT INTO ^dtp[cart] (userid, status, cartdate, changestatus) VALUES ('$workas', 'edit', '^now.sql-string[]', '^now.sql-string[]')}
	$cartid(^int:sql{SELECT LAST_INSERT_ID()}) $cart.userid[$workas] $cart.status[edit] $cart_saved[$cart_saved new]
	$cart.cartdate[^now.sql-string[]] $cart.changestatus[^now.sql-string[]]
}{
	$cartid[$cart.cart_id]
}
^cart.delete[cart_id]
^if(def $form:refresh || $change_cart_owner){
	$cart.cartdate[^now.sql-string[]]
	^void:sql{UPDATE ^dtp[cart] SET ^cart.foreach[k;v]{$k = '$v'}[, ] WHERE cart_id = '$cartid'} $cart_saved[$cart_saved updated]
}
$cart.cart_id[$cartid]
^if(!$must_create_cart){^cleancc[]}
^savecc[savecart]

@savecc[caller]
^use[/classes/compopt.p]
^if(def $cc){
^void:sql{DELETE FROM ^dtp[cartcount] WHERE cart_id = '$cart.cart_id'} $cc_saved[$cc_saved ^cc._count[]]
^void:sql{INSERT INTO ^dtp[cartcount] (cart_id, item_id, qty^if($form:mode eq refresh){, ccomment}) 
VALUES ^cc.foreach[k;v]{('$cart.cart_id', '$k', '^cc.$k.qty.int(1)'
^if($form:mode eq refresh){, 
'$n[^compopt::create[$cc.$k.description;$k]]^n.catchForm[]'^die[^n.catchForm[]]
}
)}[, ]}
}{
#^void:sql{DELETE FROM ^dtp[cart] WHERE cart_id = '$cart.cart_id'}
$emptyflag(1) $cart_saved[$cart_saved delcart]
}


############################################
#ADDITIONAL BUSINESS LAYER
############################################
@no_reg_condition[]
^if(def $seti.noreg && !def $user.id && ^cookie:tempuserid.int(0) < 5000000){
	$tmp(5000000 + ^math:random(4000000))
	$cookie:tempuserid[^tmp.format[0x%08x]]
}{
	^if(^cookie:tempuserid.int(0) > 5000000 && def $user.id && $form:a eq cart){
		$change_cart_owner(^cookie:tempuserid.int(0))
		$cookie:tempuserid[-1]
	}
}


@send_request0[]
^if($cart.status eq edit){
    ^void:sql{UPDATE ^dtp[cart] SET status = 'done', changestatus = '^now.sql-string[]' WHERE cart_id = '$cart.cart_id' AND userid = '$workas'}
}
^send_request1[]

@giveme_user0[]
^if($user0 is table){;$user0[^table::sql{SELECT * FROM ^dtp[users] WHERE id = '$workas'}]}

@totals[]
$totalsum(0) $totalweight(0) $totalqty(0)
^cc.foreach[k;v]{
 ^totalsum.inc(^eval($cc.$k.qty * $cc.$k.price)[%.8f])
 ^totalweight.inc(^eval($cc.$k.qty * $cc.$k.weight)[%.4f])
 ^totalqty.inc($cc.$k.qty)
}
$totalsum(^totalsum.double[]) ^if(!$clearsum){$clearsum(^totalsum.double[])}

#скидка по сумме (сумма==процент,,сумма==процент)
@paydiscount[comptab][ct;disc]
^if(!$discount){$discount(0)}
$ct[^expand[$comptab]]
^ct.sort($ct.param)[asc]
^ct.menu{
	^if($totalsum > $ct.param){$disc($ct.value)}
}^discount.inc($disc)
^totalsum.dec($totalsum * $disc / 100)

#распределяет общую сумму равномерно по ценам товаров.
@total2products[totalsum0][upcount;p_d]
$p_d(^if($totalqty){^eval(($totalsum - $clearsum) / $totalqty)[%.8f]}{0})
^cc.foreach[k;v]{
 $cc.$k.price(^eval($cc.$k.price + $p_d)[%.8f])
}


@quickadd[list][notpr;a]
$a[$list]
$notpr[^s2h[^list.foreach[k;v]{^if(^k.length[] <= 3){$k }}]]
^a.sub[$notpr]
^if(def $a){^a.foreach[k;v]{
  $tmp[^table::sql{SELECT item_id FROM ^dtp[shop] WHERE itemname LIKE '%$k%' AND visible = 'yes'}[$.limit(2)]]
  ^tmp.menu{ $rrr[$tmp.item_id]
    ^if(!$cc.$rrr){$cc.$rrr[$.qty(1) $.cart_id[$cart.cart_id]] $must_create_cart(1)}
  }
}}
^if($cart.cart_id < 1 && $must_create_cart){^savecart[]}

@history0[][as]
$statuslist[^statuses[]]
$usercarts[^table::sql{SELECT * FROM ^dtp[cart]
WHERE userid = '$workas' ^if(!^is_manager[]){AND (status = 'done' OR status = 'sent_not_paid')} ORDER BY cartdate DESC}]


@sl[id;comm]
^try{
^if($shop_lang is hash){;
$shop_lang[^shop_language_table[]]
$shop_lang[^shop_lang.hash[id]]
}
$result[^if(def $shop_lang.$id.text){$shop_lang.$id.text}{$comm}]
}{$exception.handled(1)^die[$exception.source $exception.comment]}

@is_seller[]
^if(def ^cando[$erpermission] && def ^cando[$.seller(1)]){$result(1)}{$result(0)}
@is_manager[]
^if(def ^cando[$erpermission] && def ^cando[$.manager(1)]){$result(1)}{$result(0)}
@link2cart[options;text]
$result[$uri^rn[?]&a=cart^if(^is_manager[]){&workas=$form:workas}^if(def $options.cartid){&cartid=$options.cartid}{&cartid=$form:cartid}]
