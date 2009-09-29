$("input#forumsubmit").click(function(){
	$(this).attr("disabled", "disabled").css("background", "url(/login/img/progress_light.gif)");
	$.ajax({
		url: "/login/modules/forum/post.htm",
		data: $("form#forumpost").serialize(),
		type: "POST",
		success: function(resp){
				$("#forumpostmsg").html(resp);
			}
	});
	return false;
})

function moveTopic(fid){
	$("#toFolder").slideUp("fast");
		$.ajax({
		url: "/login/modules/forum/moder.htm",
		data: "msgid="+PMovingId+"&a=movetopic&fid="+fid,
		success: function(resp){
				$("#move"+PMovingId).append(resp);
			}
		});
	return false;
}
