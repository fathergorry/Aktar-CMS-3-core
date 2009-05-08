$.ajaxSetup({
cache: false,
error: function (XMLHttpRequest, textStatus, errorThrown) {
  $("#ajaxerrbox").html(XMLHttpRequest.ResponseText);
}
});

$("a.ajaxhandled").click(function(){
	return ajaxlink($(this));
});



$("#closeModal").css("cursor", "hand").click(
	function(){
		$("#modalOut").fadeOut("fast");
	}
);
