$("input#forumsubmit").click(function(){
	$(this).attr("disabled", "disabled").css("background", "url(/login/img/progress_light.gif)");
	$.ajax({
		url: "/login/modules/forum/post.htm",
		data: $("form#forumpost").serialize(),
		success: function(resp){
				$("#forumpostmsg").html(resp);
			}
	});
	return false;
})
