

function XurlInit(){
$("a.ajaxhandled").unbind().click(function(){
	return ajaxlink($(this));
});
};

function ajaxlink(jqobj){
	var thistitle = jqobj.attr("title");
	if(thistitle && !confirm(thistitle)){return false;}
	else {
	jqobj.css("background", "url(/login/img/progress_light.gif)");
		$.ajax({
		url: jqobj.attr("href"),
		data: "",
		success: function(resp){
				jqobj.replaceWith(resp);
			}
		});
	}
	return false;
}

function sendPM(){
	var datastr = $("#pmform").serialize();
	$("#userboxResult").html('<img src="/login/img/progress_dark.gif">');
	$.ajax({
		type: "POST",
		url: "/login/scripts/pm_post.htm",
		data: datastr,
		success: function(resp){
				$("#userboxResult").html(resp);
			}

		
	})
	return false;
}
function PDdialog(caller, id, boxId){
	var offset = $(caller).offset();
	$(boxId).css("top", $(caller).height()+offset.top+"px").css("left", offset.left+"px").slideToggle("fast");
	PMovingId = id;
	$(caller).blur(function(){$(boxId).slideUp("fast")});
	return false;	
}
function movepm(fld){
	$("#toFolder").slideUp("fast");
		$.ajax({
		url: "/login/scripts/pm_post.htm",
		data: "msgid="+PMovingId+"&pmaction=movemsg&fld="+fld,
		success: function(resp){
				$("#msg"+PMovingId).replaceWith(resp);
			}
		});
	return false;
}
function rate(objId, obj, color, caller){
	var marks = eval(obj);
	var c="";
	for (var i in marks){c+='<a href="javascript:void(0)" onClick="rateme(\''+objId+'\','+i+','+color+')">'+marks[i][color]+'</a><br/>'};
	$("#rateBox").html(c);
	PDdialog(caller, 1, '#rateBox');
	return false;
}

function rateme(objId, markId, color){
	$("#"+objId).css("background", "url(/login/img/progress_light.gif)")	
		$.ajax({
		url: "/login/scripts/rateme.htm",
		data: "objId="+objId+"&markId="+markId+"&color="+color,
		success: function(resp){
				$("#"+objId).replaceWith(resp);
			}
		});
	return false;
}

function userbox(caller, id, wintype){
		openModal('Отправить сообщение пользователю', 
		'<span id="userboxResult" />', caller)
		$("#userboxResult").html('<img src="/login/img/progress_dark.gif">');
		$.ajax({
		type: "GET",
		url: "/login/scripts/pm_post.htm",
		data: "uid="+id+"&pmaction="+wintype,
		success: function(resp){
				$("#userboxResult").html(resp);
			}
		});
}

function openModal(head, cont, caller){
	if (caller){
		var offset = $(caller).offset();
		$("#modalOut").css("top", $(caller).height()+offset.top+"px").css("left", offset.left+"px");
	}
	$("#modalContent").html(cont);
	$("#modalHeader").html(head);
	$("#modalOut").fadeIn("fast");
}
