@feedback_settings[set;i]
$result[^table::create{param	type	default	descr
fieldlist	string		Список полей формы через пробел (пустой - все поля)
reqlist	string		Обязательные поля (через пробел)
recipient	string		E-mail получателя (ваш)
okmsg	string	Ваше сообщение было успешно отправлено	Сообщение об успешной отправке формы
errmsg	string	Не все необходимые поля формы заполнены	Сообщение об отсутствии необходимых полей
titlemsg	string	FEEDBACK FROM $env:SERVER_NAME	Заголовок почты
check_js	bool	yes	Не принимать сообщения от роботов
keep	bool	yes	Сохранять сообщения на сервере}]

@feedback_info[set;i]
#^if(def $set.recipient && !^is_email[$set.recipient]){Некорректный e-mail получателя<br>}
Создайте свою форму в тексте страницы. Она должна отправляться методом POST. Поместите эту подпрограмму в вашу форму: &lt;form> [program] &lt;/form>.
Разрешите макросы. Для получения полей формы используйте макрос [formdata^;название поля]



@feedback[set;i]
$seti[$set]
$myform[^feedbackmail::create[$seti.fieldlist;$seti.recipient;$seti.reqlist]]
^myform.checker[$seti.check_js]
^myform.collect_data[$seti.okmsg;$seti.errmsg;$seti.titlemsg]

^if(def $seti.keep && (def ^cando[$epermission] || ^cando[editor users])){
^if(def $form:view){
	$fmsg[^file::load[text;/custom/userdata/$form:view]]
	$response:body[<html><body><pre>^taint[as-is][$fmsg.text]</pre>]
}{
	$j[^file:list[/custom/userdata;\.fdb^$]]
	^j.sort{$j.name}[desc]
	^j.menu{<a href="$uri?view=$j.name">$j.name</a><br>}
}
}


@CLASS
feedbackmail

@create[fieldlist;rec;req]
^if(!def $fieldlist){$nofields(1)}
$fl[$fieldlist] 
^if($fieldlist is table){;
	$fl[^fieldlist.split[ ;v]] 
}
$recipient[^if(^is_email[$rec]){$rec;$globals.site_admin}]
$required[^s2h[$req byscriptchecker]]

@collect_data[sendmsg;errmsg;titlemsg]

^if($nofields){
 ^form:fields.foreach[k;v]{^fl.append{$k}} 
}

^if(def $form:isfeedback && ^reqfields[$errmsg]){
 ^try{^send_data[$titlemsg] $MAIN:clearformdata(1) $MAIN:document.pagetitle[$sendmsg]}{$exception.handled(0)^die[^lang[Не удалось отправить почту. Обратитесь к администратору сайта.]]}
}{^if($env:REQUEST_METHOD eq POST && ^reqfields[$errmsg]){^die[Сообщение не было отправлено. Возможно, у вас отключен JavaScript.]}}

@checker[do]
^if(def $do){^checker2[]}{<input type=hidden name=byscriptchecker value=^math:random(2000)>}
<input type=hidden name=isfeedback value=1>
@checker2[]
<script language="javascript">
var divd="byscriptchecker";
document.write("<input type=hidden name="+divd+" value=^math:random(2000)>")
</script>
<noscript>У вас отключен javascript или это визит робота. Сообщение не будет отправлено.</noscript>

@reqfields[errmsg]
$result(1)
^if(def $required){ 
 ^required.foreach[k;v]{^if(!def $form:$k){$result(0)}} 
}
^if(!$result){^if(!$errmsg_said){^die[$errmsg]}$errmsg_said(1)}

@send_data[titlemsg]
^mail:send[
      $.from[$env:HTTP_HOST visitor <web@$env:SERVER_NAME>]
      $.to[feedback recipient <$recipient>]
      $.subject[ $titlemsg --]
      $.text[
$fdb_message[
^fl.menu{$tmp[$fl.piece]^tmp.upper[]:
^try{$h[$form:tables.$tmp]^h.menu{$h.field}[ ]}{$form:$tmp $exception.handled(1)}
}]
$fdb_message

SENT BY parser-3]
]
^if(def $MAIN:seti.keep){
 ^fdb_message.save[/custom/userdata/^saveable[^MAIN:now.sql-string[]].fdb]
}