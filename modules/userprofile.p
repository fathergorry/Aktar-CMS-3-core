@version[]
2009-04-22	Каптча
2009-01-06	Возможность подтверждения e-mail'a
2008-09-20	Обрезка пароля при логине
2008-06-23	Первый
@userprofile_settings[][set]
$result[^table::create{param	type	default	descr
reqfields	option	email name	^lang[526]
hiddenfields	option	flag_a	^lang[527]
reghidden	string		Поля, скрываемые при регистрации, но видимые при изменении
modhidden	string		Поля, видимые при регистрации, но скрываемые при изменении
defrig	translit	z	^lang[528]
#editrig	translit	users	Права, разрешающие редактировать данные пользователя с правами по умолчанию
reg_ok	string	^lang[529]	^lang[530]
mailmsg	string		^lang[531]
submit	string	^lang[532]	^lang[533]
regmsg	string	^lang[534]	^lang[535]
conf_email	string		^lang[536]
^if(-f "/my/dbs/users1.txt"){alt_1	bool	yes	^lang[538]}}]

@userprofile_info[ut;ut][ut;ks;р]
$ks[^s2h[text password; ]]
^lang[539] $ut[^table::load[/my/dbs/users.txt]]
^ut.menu{$h[$ut.form_handler]^if(def $ks.$h){ $ut.column }}
^if(-f "/my/dbs/users1.txt"){;^die[540]}

################----######-----#####
@userprofile[set]
#Globalize settings
$useropt[$set]
^use[datawork.p] 
^use[adbase2.p]
#going to include this module anywhere, but keeping compartibility
$upaction[^default[$form:upaction;$form:action]] 
^connect[$scs]{
^if(def $userid){
	^switch[$upaction]{
		^case[modify;registerUser;modifyUser0]{^userform[$upaction] ^unameme[^lang[541]]}
		^case[logout]{^logout[]}
		^case[DEFAULT]{
			^if(!def $form:conf){^myinfo[]}{^conf_email[]}
		}
	}
}{
	^switch[$upaction]{
		^case[recover;cc]{^recover[] ^unameme[^lang[542]]}
		^case[register]{^userform[$upaction] ^unameme[^default[$useropt.regmsg;^lang[534]]]}
 		^case[userid]{^myinfo[]}
		^case[DEFAULT]{^login[]}
	}
}
}



@unameme[def][with]
$with[$upaction]
$document.title[^default[$useropt.$with;$def] - $env:SERVER_NAME]
$document.pagetitle[^default[$useropt.$with;$def]]

@userform[act]
^switch[$act]{
	^case[registerUser]{^unameme[Вы регистрируете нового пользователя]}
	^case[modifyUser0]{^unameme[Вы изменяете данные пользователя]}
}
#Условия выборки из базы
^if($act eq modify && $env:REQUEST_METHOD ne POST){$dw_cond[$.id($user.id)]}

$userdesc[^datawork::create[users;$dw_cond;;
	$.exclude[$useropt.hiddenfields rig extid groupid regdate ^if($upaction eq register){$useropt.reghidden } ^if($upaction eq modify){$useropt.modhidden} ]
	^if(def $useropt.alt_1){$.alternate[1]}
	^if(def $useropt.reqfields){$.required[$useropt.reqfields]}
	^if($env:REQUEST_METHOD eq POST){$.from_form[instance_name]})
]]
^if($env:REQUEST_METHOD eq POST){
^capchk[]
^if(!$userdesc.data_error){
	$user0[^userdesc.returnHash[]]
	^if($upaction eq register){
		$user0.rig[$useropt.defrig] $user0.regdate[^now.sql-string[]]
		$user0.groupid(1) $textpassword[$user0.password]
		$user0.password[^md5[$user0.password]]
	}
	^if($upaction eq modify){
		^if(!def $user0.password){
			^user0.delete[password]
		}{
			$user0.password[^md5[$user0.password]]
		}
	}
	^userdesc.save[$user0;;^if($upaction eq register){insert}{$.id($user.id)}]
	^if($upaction eq register){
		^proceed_registration[]
	}{
		^upform[]
	}
}{
	^die[543] ^upform[]
}
}{^upform[]}
@proceed_registration[]
$user[^datawork::create[users;$.id($userdesc.last_insert)]]
$user[^user.returnHash[]]$user_[$user]
$sid[^math:uid64[]] $userid($user.id)
    ^manage_session[$sid]
^if(def $user_.email){
^mailsend[
    $.from[$globals.site_admin]      $.to["$user_.name $user_.lastname" <$user_.email>]
    $.subject[^lang[545] $env:SERVER_NAME]    $.charset[$globals.mailcharset]
    $.text[^lang[546] $user_.name $user_.lastname
$useropt.mailmsg
^if(def $useropt.conf_email){
^lang[547]
http://${env:SERVER_NAME}/$uri/?conf=^md5[$user_.email $useropt.conf_email]&email=$user_.email
^lang[573]
}
^lang[548] http://$env:SERVER_NAME
^lang[549]
$user_.email
^lang[61]
$textpassword
^lang[550]]
]}{^die[user has no email]}

@conf_email[][locals]
$err(0)
$mymail[^table::sql{SELECT email, rig FROM ^dtp[users] WHERE email = '$form:email'}]
^if(!def $mymail.email){$err(1)^die[551]}
$md5em[^md5[$mymail.email $useropt.conf_email]]
^if($md5em ne $form:conf){$err(1)^die[552]}{$em_conf_ok(1)}
^if(!def $useropt.conf_email){$err(1) ^die[553]}
^if($em_conf_ok && !$err){
	$rig[^s2h[$mymail.rig]]^rig.delete[unconf]$rig.conf(1)
	^void:sql{UPDATE ^dtp[users] SET rig = '^rig.foreach[k;v]{$k }' WHERE email = '$mymail.email'}
	^die[554]
}

@upform[]
^if($env:REQUEST_METHOD eq POST && !$userdesc.data_error){
	<a href="$form:refto^rn[?]"><b><big>^default[$form:refmsg;^lang[544]]</big></b></a>
    ^if($form:refmode eq absolute){^redirect[${form:refto}^rn[?]]}
}
<form action="$uri/" method="POST" enctype="multipart/form-data">

* - ^lang[555]<br>
^keepvalue[action refto refmsg refmode allowcode upaction]
^userdesc.form[;$.tstyle[width:400px]$.nofilemsg[вы сможете загрузить файл после регистрации]]
^capshow[]
$datacloser
<input type=submit id="upsubmit" value="^default[$useropt.submit;Готово]">
</form>
@capchk[]
^if(!def $user.id){
^use[/login/captchadefault.htm]
^if(!^capchk0[]){$userdesc.data_error(1)}
}
@capshow[]
^if(!def $user.id){
^use[/login/captchadefault.htm]
<br>^capshow0[<br>]<br>
}
@logout[]
^if($sessions is hashfile){;$sessions[^hashfile::open[/cache/set/sessions]]}
^sessions.delete[$sid] $cookie:s[]
$sid[] 
^redirect[^if(def $form:refto && $form:refto ne "/login"){$form:refto^rn[?];http://$env:SERVER_NAME/^rn[?]}]
###################################

@myinfo[]
^if($userprofile_design is junction){^userprofile_design[]}{
^lang[58] $user.name!
<p>
^mypermlist[]
^mysectlist[]
}
@mypermlist[]
^lang[556]<br> $permissions[^table::load[/my/config/_permissions.txt]] $permissions[^permissions.hash[permission]]
^usercando.foreach[k;v]{^if(def $k){$k - ^lang[$permissions.$k.description] <br>}}

@mysectlist[]
^if(!def ^cando[$.editor(1)]){
$mysect[^table::sql{SELECT path, menutitle, level FROM ^dtp[structure] WHERE ^default[^usercando.foreach[k;v]{epermission LIKE '%$k'}[ OR ];0] ORDER BY path}]
^if(def $mysect){<p>^lang[266]:<br>^mysect.menu{^for[i](1;$mysect.level){&nbsp^;&nbsp^;}<a href="$mysect.path">$mysect.menutitle</a><br>}}
}
@login[][user0]
^if($env:REQUEST_METHOD eq POST){
  $user0[^table::sql{SELECT * FROM ^dtp[users] WHERE (id = '^form:id.int(-1)' OR email = '$form:id') AND password = '$tmp[$form:password]^md5[^tmp.trim[]]'}]
  ^if(def $user0){
    $user[$user0.fields] $user0[] $sid[^math:uid64[]]
    ^manage_session[$sid]
    ^if($user0.rig ne $globals.defaultrig){^log[Logged in	]}
    ^redirect[^if(def $form:refto){$form:refto}{$uri}^rn[?]]
  }{^die[^lang[558]]}
}
<form action="$uri/?action=login^rn[&]" method="post">
^keepvalue[action refto refmsg refmode upaction]
^lang[557] e-mail:<br><input type=text name=id value="$form:id"><br>^lang[61]<br><input type=password name=password><br>
<input type=submit value="^lang[209]"></form>
<a href="$uri?upaction=register">^lang[559]</a> |
<a href="$uri?upaction=recover">^lang[280]</a>
###################################

@recover[][np;user0;check]
^if($env:REQUEST_METHOD eq POST){
  $user0[^table::sql{SELECT email, name, id, password FROM ^dtp[users] WHERE id = '^form:id.int(-1)' OR email = '$form:id'}]
  ^if(def $user0){
    ^msg[560]
    ^mailsend[
    $.from[$globals.site_admin]      $.to["$user0.name" <$user0.email>]
    $.subject[^lang[561] $env:SERVER_NAME]    $.charset[$globals.mailcharset]
    $.text[^lang[58] $user0.name
^lang[562]
http://${env:SERVER_NAME}${uri}?id=$user0.id&cc=^user0.password.left(15)&action=cc
^lang[563]]
    ]
  }{^die[564]}
}
^if(def $form:cc){
  $check[^table::sql{SELECT email, name, id, password FROM ^dtp[users] WHERE id = '^form:id.int(-1)'}]
  ^if(def $check && ^check.password.left(15) eq "$form:cc"){
    $np[^password_generate[]]^void:sql{UPDATE ^dtp[users] SET password = '^md5[$np]' WHERE id = '$check.id'}
    ^mailsend[
    $.from[$globals.site_admin]      $.to["$check.name" <$check.email>]
    $.subject[^lang[565] $env:SERVER_NAME]    $.charset[$globals.mailcharset]
    $.text[^lang[58] $check.name
^lang[566]
$np
^lang[567] http://${env:SERVER_NAME}${uri}^rn[?] ]
    ] ^msg[568] ^login[]
  }{^die[552]}
}{<form action="$uri/?action=recover^rn[&]" method=post>
^lang[557] e-mail:<br><input type=text name=id><br>
<input type=submit value="^lang[569]"></form><p><a href="$uri^rn[?]">^lang[209]</a>}
####################################

@password_generate[][g;s;p;r;v]
$g[aoeui] $s[qrtpsdfghjklzxcvbnm]
#$g[аоуыэяёюие] $s[йцкнгшщзхфвпрлджчсмтб]
^for[i](1;8){ ^if($v eq $s){$v[$g]}{$v[$s]}
  $r(^math:random(^if($v eq $s){19}{5})) $p[${p}^v.mid($r;1)]
}
$result[${p}^math:random(99)]

@users_password[p]

^if($upaction eq modify){Старый пароль;Введите пароль (только латинские буквы и цифры)} <br>
<input type="password" name="users_password"><br>
^if($upaction eq modify){Новый пароль}{Повторите пароль}<br>
<input type="password" name="users_password_confirm"><p>

@check_password[p][pc] notice that in 'register' there is entered string, in 'modify' - MD5
$pc[$form:users_password_confirm] $result[$p]
^if($upaction eq register){
	^if(def $p && $pc ne $p){
		^throw[check;;Вы ошиблись в подтверждении ввода пароля]
	}{
		^if(def $p){
			$result[$p]
		}{
			$result[^password_generate[]]
		}
	}
}
^if($upaction eq modify){$result[]}
^if($upaction eq modify && def $pc){
	$tmp[^table::sql{SELECT password FROM ^dtp[users] WHERE id = '$user.id' AND password = '^md5[$p]'}]
	^if(def $tmp.password){
		$result[$pc]
		^msg[Пароль изменен]
	}{
		^msg[Пароль не был изменен]
	}
}
