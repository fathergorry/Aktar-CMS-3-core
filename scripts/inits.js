$.ajaxSetup({
cache: false,
error: function (XMLHttpRequest, textStatus, errorThrown) {
  $("#ajaxerrbox").html(XMLHttpRequest.ResponseText);
}
});

XurlInit();



$("#closeModal").css("cursor", "hand").click(
	function(){
		$("#modalOut").fadeOut("fast");
	}
);
