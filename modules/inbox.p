@version[]
2009-01-07	first

@inbox_settings[set;i]
$result[^table::create{param	type	default	descr
msgcnt	num	30	Сообщений на странице}]

@inbox_info[set;i]
      

@inbox[set;i]
<nobr>^mymsg:menu[]</nobr>
$seti[$set]
^if(def $user.id){^connect[$scs]{
	^switch[$form:pmact]{
		^case[write]{^mymsg:write[$form:to]}
		^case[DEFAULT]{^mymsg:list[$user.id]}
	}
}}{^die[Служба приватных сообщений доступна только для зарегистрированных пользователей.]}


$extrahtml[$extrahtml ^mymsg:movedialog[]]

@CLASS
mymsg

@auto[]
$folders[^table::create{fld	desc
un	Непрочитанные
re	Прочитанные
sv	Важные
sp	Спам
dl	Корзина}]
^if(def $form:folder && ^folders.locate[fld;$form:folder]){$MAIN:document.pagetitle[${MAIN:document.pagetitle}: $folders.desc]}
^if($form:folder eq sent){$MAIN:document.pagetitle[Отправленные]}
@menu[pref;div]
^folders.menu{<a href="^default[$pref;$MAIN:uri?]folder=$folders.fld^rn[&]">$folders.desc</a>^default[$div; | ]}<a href="^default[$pref;$MAIN:uri?]folder=sent">Отправленные</a>

@movedialog[]
<div id="toFolder" style="width:110px" class="dialogbox">
$f[^folders.select($folders.fld ne "$form:folder")]
^f.menu{
	<a href="#" onClick="movepm('$f.fld')">$f.desc</a><br>
}
</div>



@list[id]

^if($form:folder eq dl){
	^if(def $form:delete){
		^void:sql{DELETE FROM ^dtp[privmsg] WHERE recipe = '$id' AND folder = 'dl'}
		^msg[Корзина очищена.]
	}{
		<a href="$uri?folder=dl&delete=yes^rn[&]">Очистить корзину</a>
	}
}

$msgs[^table::sql{
	SELECT m.*, u.name, u.lastname, u.rig, u2.id AS rid, u2.rig AS rrig, CONCAT(u2.name, ' ', u2.lastname) AS rname FROM ^dtp[privmsg] m 
	LEFT JOIN ^dtp[users] u ON m.author = u.id 
	LEFT JOIN ^dtp[users] u2 ON m.recipe = u2.id
	^if($form:folder eq sent){
		WHERE m.author = '$id'
	}{
		WHERE m.recipe = '$id' 
		AND m.folder in (^if(def $form:folder){'$form:folder'}{'un', 're'}) 
	}
	ORDER by m.msgdate DESC LIMIT ^MAIN:seti.msgcnt.int(30)
}]
^if(^msgs.count[] == 0){^msg[Сообщений нет]}


<p></p>
^msgs.menu{
	$sndrig[^s2h[$smsgs.rig]]
	<div class="message $msgs.folder">
	<div class="sender">
	^userbox[$msgs.author;$msgs.rig;$msgs.name $msgs.lastname]
		^if($form:folder eq sent){
			-> ^userbox[$msgs.recipe;$msgs.rrig;$msgs.rname]
		} 
	| ^ufdate[$msgs.msgdate] 
	^if($form:folder ne sent){
		| <a class="pmop" href="#" id="msg$msgs.id" onClick="PDdialog(this, $msgs.id, '#toFolder')">переместить в...</a>
	}</div>	
	^if(def $msgs.title){<div class="msgtitle">$msgs.title</div>}
	<div class="msgcontent">^msgs.content.replace[^unbrul[]]</div>
	</div>
}
@write[to]
^use[/classes/datawork.p]
$msg[^datawork::create[privmsg]]

@userbox[id;rig;name;opt][locals]
<span class="$rig" ^if($id == $MAIN:user.id){f}{ style="cursor:hand" }onClick="userbox(this, $id, 'pmsend')">$name</span>
