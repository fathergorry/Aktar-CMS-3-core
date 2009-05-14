@version[]
2008-02-27	Добавлена поддержка премодерации и убрана каптча для зарегистрированных

@forum_settings[options]
$result[^table::create{param	type	default	descr
fid	string	$i[^uri.split[/;rh]]^i.0.left(32)	Идентификатор форума
rpp	num	15	записей на странице
#is_spec	bool		Этот форум является консультацией специалиста
#file_ext	option		Расширения разрешенных файлов (через пробел)
#file_size	num		Ограничение на размер файла
notify	string		Email, на который отправлять уведомления о новых постах
forum_descr	string		Описание форума
reged	bool	yes	Только зарегистрированные могут постить
premod	bool	yes	Премодерация постингов
specans	string		Права, разрешающие ответ (пустое поле - отвечают все)
ansbgr	string		Цвет фона для ответов
norate	bool	yes	Отключить голосования}]
@forum_info[set]
Права на модерирование: moder
^try{
$inf[^table::sql{SELECT DISTINCT fid , COUNT(fid) AS coun 
FROM ^dtp[forum] GROUP BY fid ORDER BY coun DESC LIMIT 10}]
<br> Имеющиеся идентификаторы (непустые): ^inf.menu{$inf.fid ($inf.coun)}[, ].
}{^blad[huinia]}
@forum[set]

^forum:operate[$set]

@CLASS
forum

@operate[set]
$seti[$set]

^if($MAIN:document.module ne "forum.p"){$seti.embedded(1)}
^if(!def $seti.specans){$canans(1)}{
	^if(def ^cando[^s2h[$seti.specans]] || ^moder[]){$canans(1)}
}

^if(!def $seti.fid){$seti.fid[default]$allid[^s2h[$seti.fid]]}{$allid[^s2h[$seti.fid]]$tmp[^seti.fid.split[ ;lh]]$seti.fid[$tmp.0]}
^if(def $form:msg){^die[$form:msg]}

^connect[$MAIN:scs]{
^if(^moder[] && def $form:edit){^editone[]}{
^if(^form:fdisplay.int(0) > 0){^showf1[^form:fdisplay.int(0)]}{^showall[]}
}
^if(((def $seti.reged && def $MAIN:user.id) || !def $seti.reged) && !def $form:noform){^post_form[]}
}
^call_js[/login/modules/forum/forum.js]

@urido[]
^if($MAIN:document.module eq "forum.p"){$result[$MAIN:uri?]}{
$result[$request:uri^if(^request:uri.pos[?]>0){&;?}]
}

@fcapchk[]
^if(!def $seti.reged && !def $MAIN:user.id){
^use[/login/captchadefault.htm]
^if(!^capchk0[]){$userdesc.data_error(1)}
}
@fcapshow[]
^if(!def $seti.reged && !def $MAIN:user.id){
^use[/login/captchadefault.htm]
<br>^capshow0[<br>]<br>
}
@showf1[id]
^if($env:REQUEST_METHOD eq POST && !def $seti.reged){^post_answer[]}


$message[^getmessage[$id]]
^if(def $message.content){$message.content[^message.content.replace[^unbrul[]]]}
$answers[^table::sql{SELECT * FROM ^dtp[ans] WHERE id = '$id'}]
^if($MAIN:message_design is junction){^message_design[]}{
 $MAIN:document.title[$message.title - $message.author - $MAIN:document.title]
^if(!$seti.embedded){
^MAIN:crumbs.append{$MAIN:uri?fdisplay=$form:fdisplay	^wisetrim[$message.title;16]}
 $MAIN:document.pagetitle[^default[$message.title;Сообщение] - $MAIN:document.pagetitle] $MAIN:document.keywords[$message.title] $MAIN:document.content[]
}{<h2>^default[$message.title;Сообщение]</h2>}
  Пишет <b>$message.author</b> (^dmy[$message.mydate]) <br>
  ^process_content[$message.content]
  <h3>Ответы на «${message.title}»</h3>
  ^answers.menu{<span id="forumbox$answers.ansid"><hr size="1">
    ^if(def $answers.title){<b>$answers.title</b> - }$answers.author^if(def $answers.email){ (^email[$answers.email])},   ^dmy[$answers.mydate]<br>
    
    ^process_content[$answers.content]
    <br>
    ^ansadmin[$answers.ansid]
    <br>
  </span>}
  ^if(^answers.count[] < 1){Еще никто не ответил на это сообщение.}
^if(def $form:noform){<p><a href="^urido[]^rn[?]">Вернуться в форум</a><p>}
  
}
$message[$.author[$MAIN:user.name]$.email[$MAIN:user.email]]
@ansadmin[id]
^if(^moder[]){<a href="/login/modules/forum/moder.htm?a=del&ansid=$id" title="Удалить этот ответ?" class="ajaxhandled">удалить</a>}
@process_content[c][text]
#$text[^try{^process{^untaint{$c}}}{$exception.handled(1)$c}]
$result[^c.replace[^unbrul[]]]
@post_answer[]
^use[collection.p]
$ans1[^collection::create[ans]]
$ans_message[^ans1.createInstance[postid whois title author email content]]
$ans_message.mydate[^MAIN:now.sql-string[]]
$ans_message.whois[^if(^moder[]){spec}{user}]
$ans_message.id[^form:fdisplay.int(-1)]
$ans_message.content[^utf2win[$ans_message.content]]
$ans_message.author[^utf2win[$ans_message.author]]
^fcapchk[]
^if(!def $form:author){$forum_err(1)^die[Необходимо заполнить Ваше имя]}
^if(def ^string:sql{SELECT postid FROM ^dtp[ans] WHERE postid = '$form:postid'}[$.default{} $.limit(1)]){^die[Вы уже отправили это сообщение]$forum_err(1)}
^if(!$forum_err){

$author_want[^table::sql{SELECT email, author, iwantcomment FROM ^dtp[forum] WHERE id = '^form:fdisplay.int(0)'}]


<!-- ^ans1.insertInstance[$ans_message] ^msg[Ответ добавлен]-->
#^redirect[^urido[]fdisplay=$form:fdisplay^rn[&]]
^void:sql{UPDATE ^dtp[forum] SET answers = answers + 1 WHERE id = '^form:fdisplay.int(-1)'}


^if($author_want.iwantcomment eq yes && ^is_email[$author_want.email]){^try{
^mail:send[
  $.from["$env:SERVER_NAME Forum" <$globals.site_admin>]      $.to["$author_want.author" <$author_want.email>]
    $.subject[Ответ от $ans_message.author]    $.charset[$globals.mailcharset]
    $.text[Здравствуйте, $author_want.author
На ваше сообщение в форуме поступил ответ от $ans_message.author
http://${env:SERVER_NAME}^urido[]fdisplay=$form:fdisplay

$ans_message.title
$ans_message.content
]
]
^msg[Автору темы отправлено уведомление об ответе.]
}{$exception.handled(1)^die[не удалось отправить почту]}}

#end if !$forum_err
}

@getmessage[id][tmp]
$tmp[^table::sql{SELECT * FROM ^dtp[forum] WHERE id = '$id'}]
$result[$tmp.fields]


@fsel[]
$r(^int:sql{SELECT COUNT(id) FROM ^dtp[forum] WHERE fid IN (^allid.foreach[k;v]{'$k'}[, ])})
$pp[^pagination::create[$r;^seti.rpp.int(15)]]
$forum[^table::sql{
	SELECT * FROM ^dtp[forum] WHERE fid IN (^allid.foreach[k;v]{'$k'}[, ])
	^if(!^moder[]){AND visiblity = 'yes'} 
	ORDER BY mydate DESC
}[^pp.q[limits]]]
$fans[^table::sql{SELECT * FROM ^dtp[ans] WHERE id IN (^forum.menu{'$forum.id', }'-1')
 ORDER BY mydate ASC}]

@showall[]
^if($env:REQUEST_METHOD eq POST && !def $seti.reged && def $form:author){^post_message[]}
^fsel[]
 $seti.forum_descr
<style>.ans{margin-left:30px^;margin-top:8px^;padding:2px}</style>
^use[rating.p]
^rating:addrange[^forum.menu{f$forum.id}[
]
^fans.menu{a$fans.ansid}[
]]
^forum.menu{<span id="forumbox$forum.id" class="forumbox">
<span class="isUser" onClick="userbox(this, 22, 'pmsend')"></span><a href="^urido[]fdisplay=$forum.id"><b>$forum.title</b></a> - 
^if($forum.userid && ^moder[]){<a href="/login/users.htm?uid=$forum.userid">}
$forum.author</a>^if(def $forum.email){ (^email[$forum.email])},
^ufdate[$forum.mydate] ^ratingbox[f$forum.id]
^if(def $forum.content){<br>^forum.content.replace[^unbrul[]]} 
<br>^if($canans){<a href="^urido[]fdisplay=$forum.id#msgForm"><img src="/login/img/edit.gif" border=0><b>Написать ответ</b></a>}

	^if(^moder[]){
	<a class="ajaxhandled" href="/login/modules/forum/moder.htm?a=screen&id=$forum.id&show=^if($forum.visiblity eq yes){off">скрыть;on"><img src="/login/img/eye.gif" border=0>показывать}</a>
	<a href="/login/modules/forum/moder.htm?a=del&id=$forum.id" class="ajaxhandled" title="Точно удалить это сообщение и все ответы?">удалить</a> 
	}
$this_ans[^fans.select($fans.id == $forum.id)]
^if(^this_ans.count[]>0){
	^this_ans.menu{
		<div class="ans" ^if(^math:frac(^this_ans.line[]/2)){style="background-color:#$seti.ansbgr"}>
		<b><span class="isUser"></span>$this_ans.title $this_ans.author</b>,   ^dmy[$this_ans.mydate] ^rating:box[a$this_ans.ansid]<br>
		^this_ans.content.replace[^unbrul[]] ^ansadmin[$this_ans.ansid]
	</div>}
}
#<a href="^urido[]fdisplay=$forum.id">Ответов: $forum.answers</a>

  <br><br>

</span>}

^pp.listpages[ | ;$.url[^urido[]]$.prescript[Страницы:]] <br><br>

@ratingbox[id]
^if(!def $seti.norate){^rating:box[$id]}

@post_message[]
^use[collection.p]
$forum1[^collection::create[forum]]
$newpost[^forum1.createInstance[postid title author content email fid visiblity has_answer answers iwantcomment]]
$newpost.userid($MAIN:user.id)
$newpost.mydate[^MAIN:now.sql-string[]]
$newpost.title[^utf2win[$form:title]]
$newpost.author[^utf2win[$form:author]]
$newpost.content[^utf2win[$form:content]]
^if(def $seti.premod){$newpost.visiblity[no]}

^if(def ^string:sql{SELECT postid FROM ^dtp[forum] WHERE postid = '$form:postid'}[$.default{}]){^die[Вы уже отправили это сообщение]$forum_err(1)}
^if(!def $newpost.author || !def $newpost.title){^die[Необходимо заполнить Заголовок сообщения и Ваше имя]$forum_err(1)}
^fcapchk[]
^if(!$forum_err){
  $msgId(^forum1.insertInstance[$newpost])
^if(!$ajaxcalled){
  ^redirect[^urido[]fdisplay=$msgId^rn[&]&msg=Ваша запись добавлена.^if(def $seti.premod){Она появится после проверки модератором.}&noform=true]]
}{^die[Сообщение добавлено]}
^if(def $seti.notify){
  ^mail:send[
  $.from["$env:SERVER_NAME Forum" <$globals.site_admin>]      $.to["$env:SERVER_NAME Forum supervisor" <$seti.notify>]
    $.subject[Новое сообщение в форуме]    $.charset[$globals.mailcharset]
    $.text[В форум поступило сообщение от $newpost.author
http://${env:SERVER_NAME}^urido[]fdisplay=$msgId

$newpost.title
$newpost.content
]
   ]
}
}


@post_form[mode]
^if(def $form:fdisplay && $canans || !def $form:fdisplay){
	^post_form2[$mode]
}

@post_form2[mode]
^if(!def $message){$message[ $t[^math:uid64[]]$.postid[^t.left(12)] $.author[$MAIN:user.name] $.email[$MAIN:user.email] $.fid[$seti.fid] ]}
#mode forum ans spec_ans

^if($seti.embedded && !def $form:fdisplay){<h3><a href="#" onClick="^$('#fpostbox').show('slow')^;return false">Оставить комментарий</a></h3><div id="fpostbox" style="display:none">}{<div id="fpostbox"}
<h2>^if(def $form:fdisplay){Ваш ответ на}{Ваше} сообщение</h2>
^if(def $form:fdisplay && !$seti.embedded){ (<a href="^urido[]^rn[?]#msgForm">написать сообщение в форуме</a>) }
<span id="forumpostmsg"></span>
<a name="msgForm"> </a>
<form action="^urido[]fdisplay=$form:fdisplay" method=post name=post id="forumpost" enctype="multipart/form-data">
^keepvalue[fdisplay]
<input type=hidden name="id" value="$message.id">
<input type=hidden name="postid" value="$message.postid">
<input type=hidden name="fid" value="$message.fid">
^if(!def $form:fdisplay){* Заголовок сообщения<br>
<input type=text size=60 name="title" value="$message.title"><br>}
* Ваше имя<br>
<input type=text size=30 name="author" value="^if(def $form:author && !def $message.author){$form:author}$message.author"><br>
Ваш e-mail (будет защищен от спама^; может быть использован для дальнейшей связи с Вами):<br>
<input type=text size=30 name="email" value="$message.email">
^if(!def $form:fdisplay){<input type=checkbox name=iwantcomment value="yes">уведомить меня об ответе}<br>
Текст сообщения: <br>
^if($mode eq spec_ans){^carea[]}{<textarea name=content cols=50 rows=10>^if(def $form:content && !def $message.content){$form:content}$message.content</textarea>}
^fcapshow[]
<br>

<input type=submit value="Отправить" id="forumsubmit">
^if(def $seti.premod && !def $form:fdisplay){<br>Ваше сообщение появится после проверки модератором}
</form>
</div>
@carea[]
<script language="JavaScript" src="/login/scripts/ss.js">
</script>
 ^include[/login/_controls.html]
<textarea cols=50 rows=10 name="content" onselect="storeCaret(this);" onclick="storeCaret(this);" onkeyup="storeCaret(this);">^taint[as-is][^content_foredit[$exmp.content]]</textarea><a href="javascript:emoticon(':more:')">разбивка</a>

@moder[]
^if(def ^cando[$epermission] || (def ^cando[$rpermission] && def ^cando[$.moder(1)])){$result(1)}{$result(0)}
