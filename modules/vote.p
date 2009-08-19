@version[]
2008-03-20	Deity, users и editor голосуют многажды

@vote_settings[set]

$result[^table::create{param	type	default	descr
editing	bool	yes	Разрешить создание голосований всем посетителям
hidetext	bool	yes	Скрывать текстовые комментарии}]

@vote_info[set]


@vote[set;i]
^if($seti is hash){;$seti[$set]}
$vote1:seti[$seti]
^if(def $form:editing && (def $seti.editing || def ^cando[editor] || def ^cando[$erpermission])){
	^vote_editor[]
	$document.pagetitle[Создание голосования]
}{
	$edit_flag[$seti.editing]
	^voting[]
	^if(def $edit_flag || def ^cando[editor] || def ^cando[$erpermission]){
		^if(def $form:is_vote){<hr>}<a href="$uri?editing=1">Создайте свой опросник (голосование)!</a>
	}
}
	


@voting[]
^if(def $form:is_vote && !def $seti.name){
	$curr_votes[^hafala:open[/my/deriv/votesource]]
	$tmpv[^h2s:createh[$curr_votes.[$form:is_vote]]]
	^if(def $tmpv.name && def $tmpv.q1){
		$seti[$tmpv]
	}
}

^if(def $seti.name && def $seti.q1){
	^if(def $form:mode){$type2(1)}
	$myvote[^vote1::create[$seti;^if($type2){1};^if($type2){51}]]
	^myvote.manage_vote[]
}



@vote_editor[]
$votes[^hafala:open[/my/deriv/votesource]]
^if(def $form:vote_done){
	^if(def $form:name && def $form:q1){
		^save_vote[]
	}{
		^die[Необходимо заполнить название и первый вопрос. <a href="javascript:history.back(-1)">Назад</a>]
	}
}{
^if(def $form:add_vote){
$tt[^vote1::create[$form:fields;^if(^form:editing.int(0)==2){51}]]
^if(def $votes.[$tt.vid]){^die[Такое голосование уже есть. Если не вы его создавали, измените его название.]}
<h2>Так пойдёт?</h2>
<div style="background-color:#FFFF99^; width: 500px^; padding: 5px">
^tt.display_vote[noform]
</div>
Если всё правильно, нажмите  "сохранить опрос", если нет - продолжайте редактирование.<br>
}
^vote_form[$form:fields]
}
@save_vote[]
$a[^hash::create[]]
^form:fields.foreach[k;v]{^if(def $v){$a.$k[^v.left(128)]}}
^a.sub[^s2h[vote_done add_vote]]
$done_vote[^vote1::create[$a;^if(^form:editing.int(0)==2){51}]]
$tmp[^h2s:createh[$votes.[$done_vote.vid]]]
^if(def $tmp.name || def $tmp.q1){
	^die[Голосование уже сохранено, вы не можете его редактировать]
}{
	$votes.[$done_vote.vid][$.value[^h2s:h2s[$a]] $.expires(180)]
}
Скопируйте себе этот код:<br>
$tm[^done_vote.display_vote2[absolute]]
$tm[^tm.replace[^table::create{from	to
^taint[^#0A]	}]]
<textarea cols="50" rows="5" onFocus="this.select()">$tm <a href="http://${env:HTTP_HOST}$uri?is_vote=$done_vote.vid^if(^form:editing.int(0) == 2){&mode=2}">результаты</a> 
^if(def $seti.editing){<br><a href="http://${env:HTTP_HOST}$uri?editing=1^rn[&]"><small>Создайте свой опросник(голосование)! Быстро, легко и без регистрации.</small></a>}</textarea><br>
Или <a href="http://${env:HTTP_HOST}$uri?is_vote=$done_vote.vid^if(^form:editing.int(0) == 2){&mode=2}">ссылку</a> на голосование.<br>

@vote_form[fdata]
$qcount(^if(^form:editing.int(0)==2){1;7})
$acount(^if(^form:editing.int(0)==2){50;9})

<p>С помощью нижележащей формы вы можете создать свою форму для голосований.  <br>
^if($env:REQUEST_METHOD ne POST){
	^if(^form:editing.int(1) == 1){
		Сейчас в вашей анкете допускается максимум 7 вопросов, по 9 ответов в каждом</b> <a href="$uri?editing=2">Вариант с 1 вопросом и 50 ответами</a>
	}{
		Сейчас в вашей анкете допускается максимум 1 вопрос c 50 ответами</b> <a href="$uri?editing=1">Вариант с 7 вопросами по 9 ответов</a>
	}
}
<small><br>* - обязательно заполните название и первый вопрос.</small>
<form action="$uri?add_vote=1" method=post>
^if($env:REQUEST_METHOD eq POST){^saves[]<p>}
^keepvalue[add_vote editing]
<b>* Название (заголовок) голосования:</b><br>
<input type=text name=name value="$fdata.name" size=80><p>
^for[i](1;$qcount){
<fieldset>
<legend><b>^if($i==1){* }Вопрос №$i </b>^if($i > 3){<small>не обязательно заполнять все вопросы</small>}</legend>
<div style="padding-left: 15px">
<input type=text name=q$i value="$fdata.q$i" size=50><p>
<b>Тип ответа:</b> <br> $th[^expand[radio==выбор одного (крыжик),,select==выбор одного (выпад. список),,checkbox==выбор нескольких^if(^form:editing.int(0) !=2){,,text==ввод текста}]]

^th.menu{<input type=radio onFocus="document.getElementById('anss$i').style.display='^if($th.param eq text){none}{block}'" name=s$i value="$th.param" ^if($fdata.s$i eq $th.param){checked}>$th.value }

<blockquote id="anss$i" style="display:^if($fdata.s$i eq text){none}{block}">
<b>Ответы</b>:<br>
^for[j](1;$acount){
	$tmp[a${i}_$j]
	${j}: <input type=text name=$tmp value="^if($fdata.s$i ne text){$fdata.$tmp}" size=50>
}[<br>]
</blockquote></div>
</fieldset>
}[<p>]
^saves[]

@saves[]
<input type=submit value="Посмотреть, как выглядит Ваш опрос">
^if(def $form:add_vote){
<input type=submit name="vote_done" value="Сохранить голосование">
}
#############################################################################
@CLASS
vote1

@auto[]
$seti[^hash::create[]]

@create[s;lim0;limAns][qmax]
$vote_settings[$s] $ilimit(^default[$lim0;15]) $alimit(^default[$limAns;$ilimit])
$vtitle[^default[$s.name;$s.q1]]
$vid[$s.name $s.q1] $vid[^md5[^vid.lower[]]] $vid[^vid.right(20)]
$user9[^md5[$env:REMOTE_ADDR $env:HTTP_USER_AGENT $vid]]
$userpool[^hashfile::open[/my/deriv/votepool]]
$votedata[^hashfile::open[/my/deriv/votedata]]
^if(def $userpool.$user9 && !def ^cando[editor users]){$answered(1)}

$questions[^table::create{qid	qname	qtype}]
^for[i](1;$ilimit){
	^if(def $s.q$i){^questions.append{$i	$s.q$i	$s.s$i} $qmax($i)}
}

$answers[^hash::create[]]

^for[i](1;$qmax){
	$answers.$i[^table::create{aid	aname}]
	^for[j](1;$alimit){
		$tmp[a${i}_$j]
		^if(def $s.$tmp){
			^answers.$i.append{$j	$s.$tmp}
		}
	}
}


@manage_vote[]

^if(^questions.count[] >=1 ){
	^if(def $form:is_vote && !$answered && $env:REQUEST_METHOD eq POST){
		^update[]
	}
	^if(!$answered){^display_vote[]}{^show_result[]}
}{
У этого голосования нет вопросов.
}

@show_result[]
^if(!def $adata_in){
	$adata_in[^hashf_adata[]]
}

$preres[^result1[]]
^result1[]

@result1[]

^if(!$amax){$amax(1)}
<h3 class="vote_title">$vtitle</h3><p>
<style>
.mm {vertical-align: middle}
</style>
^questions.menu{
	$qid($questions.qid) $qtype[$questions.qtype] $atab[^answers.$qid.hash[aid]]
	<b><span class="question_name">$questions.qname</span></b><p><DIV class="vote_answers">
	$tmpt[^expand[$adata_in.$qid]]
	$p100(0)
	^tmpt.menu{^if($qtype eq text || $qtype eq textarea || ^tmpt.value.int(-1) <= 0){;^p100.inc($tmpt.value) }}
	^try{^tmpt.sort($tmpt.param)[ASC]}{$exception.handled(1)}
	^tmpt.menu{
		^if($qtype eq text || $qtype eq textarea){
			^if(def ^cando[editor] || def ^cando[$erpermission] || !def $seti.hidetext){^if(def $tmpt.value){<a href="http://$tmpt.value">}<span class="vote_answer">$tmpt.param</span></a>}
		}{
			$atab.[$tmpt.param].aname<br>
			$divwidth(($tmpt.value * 100)/$amax)
			^if($tmpt.value > $amax){$amax($tmpt.value)}
			$anshtml[
			<SPAN style="WHITE-SPACE: nowrap">
<IMG class="mm" height=14 src="/login/img/icons/leftbar.gif"><IMG class="mm" height=14 alt="" src="/login/img/icons/mainbar.gif" width=^eval($divwidth * 2)[%.0f]><IMG class="mm" height=14 alt="" src="/login/img/icons/rightbar.gif" width=7>
			<B>$tmpt.value</B> (^eval($tmpt.value * 100 / ^if($p100 == 0){1;$p100})[%.1f]%)</SPAN><br>
			] ^if($tmpt.value >= 0){$anshtml}
		}
	<br>}
</div>}[<p>]
^if(def $seti.hidetext){текстовые комментарии скрыты}{DD}

@hashf_adata[][ad]
$ad[^hash::create[]]}
^questions.menu{
	$ad.[$questions.qid][$votedata.[${vid}$questions.qid]]
}
$result[$ad]

@update[]
$userpool.$user9[$.value[1] $.expires(4)]
$adata_in[^hashf_adata[]]
$notp[^notpresent[]]


^questions.menu{
	$tmp($questions.qid)
	^if($questions.qtype eq "text" || $questions.qtype eq textarea){
		$atmp[$form:a$tmp]  $atmp[^utf2win[$atmp]] $btmp[^env:HTTP_REFERER.mid(7;99)]
		$tmpans[$adata_in.$tmp^if(def $atmp){,,$atmp^if(^btmp.pos[$env:HTTP_HOST] != 0){==$btmp}}]
		$tmpans[^tmpans.right(7900)]
		$adata_in.$tmp[^tmpans.trim[both;,=]]
	}{
		$tmpans[^hash::create[]]
		$att[^expand[$adata_in.$tmp]]
		^att.menu{
			$tmp2[^att.param.int(-1)]
			$tmpans.$tmp2(^att.value.int(-1))
		}
		^answers.$tmp.menu{
			$aid($answers.$tmp.aid)
			$atf[^formtables_def[a$tmp]]
			^if(^atf.locate[field;$aid]){
				$tmpans.$aid(^eval($tmpans.$aid + 1))
			}
		}
		^tmpans.delete[-1]
		$adata_in.$tmp[^tmpans.foreach[k;v]{${k}==${v}}[,,]]
	}

}

^adata_in.foreach[k;v]{
	$votedata.[${vid}$k][$.value[$v] $.expires(30)]
}
$answered(1)
#^redirect[${uri}^rn[?]]

@notpresent[][notp]
$notp[^hash::create[]]
^questions.menu{$tmp[$questions.qid]
	^if(!def $adata_in.$tmp){$notp.$tmp(1)}
}
$result[$notp]


@display_vote[param;param2]
^if($param ne noform){<form action="^if($param eq absolute){http://${env:HTTP_HOST}$MAIN:uri}{$MAIN:uri}" method=post Class="vote_form" ^if($param eq absolute){target="_blank"}>}
<input type="hidden" name="is_vote" value="$vid">
^if(^form:editing.int(0) == 2 || ^form:mode.int(0) == 2){<input type=hidden name=mode value=2>}
<h3 class="vote_title">$vtitle</h3><p>

^questions.menu{
	<strong><span class="question_name">$questions.qname</span></strong><br><DIV class="vote_answers">
	$tmp($questions.qid) $frm[$questions.qtype]
	^if($frm ne text && $frm ne textarea){
		^switch[$frm]{
			^case[select]{<select name="a$tmp" class="vote_select">
				^answers.$tmp.menu{
					<option value="$answers.$tmp.aid">$answers.$tmp.aname</option>
				}
			</select><br>}
			^case[checkbox]{
				^answers.$tmp.menu{
					<input type=checkbox name="a$tmp" value="$answers.$tmp.aid" class="vote_checkbox">
					<span class="vote_answer">$answers.$tmp.aname</span><br>
				}
			}
			^case[DEFAULT]{
				^answers.$tmp.menu{
					<input type=radio name="a$tmp" value="$answers.$tmp.aid" class="vote_radio">
					<span class="vote_answer">$answers.$tmp.aname</span><br>
				}
			}
		}
	}{
		^if($frm eq text){
		<input type="text" class="vote_text" name="a${tmp}" size="50"><br>
		}{
		<textarea class="vote_textarea" name="a$tmp"></textarea><br>
		}
	}
</div>}
<input type=submit value="^default[$s.submit;Проголосовать!]">
 ^if($param ne noform){</form>}

@display_vote2[param;param2]
^if($param ne noform){<form action="^if($param eq absolute){http://${env:HTTP_HOST}$MAIN:uri}{$MAIN:uri}" method=post Class="vote_form" ^if($param eq absolute){target="_blank"}>}
<input type=hidden name=is_vote value=$vid>
^if(^form:editing.int(0) == 2 || ^form:mode.int(0) == 2){<input type=hidden name=mode value=2>}
<h3 class="vote_title">$vtitle</h3><p>
^questions.menu{
<b>$questions.qname</b><br>
$tmp($questions.qid) $frm[$questions.qtype]
^if($frm ne text && $frm ne textarea){
^switch[$frm]{
^case[select]{<select name="a$tmp">
^answers.$tmp.menu{
<option value="$answers.$tmp.aid">$answers.$tmp.aname</option>
}
</select><br>}
^case[checkbox]{
^answers.$tmp.menu{
<input type=checkbox name="a$tmp" value="$answers.$tmp.aid">
$answers.$tmp.aname<br>
}
}
^case[DEFAULT]{
^answers.$tmp.menu{
<input type=radio name="a$tmp" value="$answers.$tmp.aid">
$answers.$tmp.aname<br>
}
}
}
}{
^if($frm eq text){
<input type=text name="a${tmp}" size="50"><br>
}{
<textarea name="a$tmp"></textarea><br>
}
}
}
<input type=submit value="^default[$s.submit;Проголосовать!]">
^if($param ne noform){</form>}

