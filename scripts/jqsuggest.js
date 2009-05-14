
/*
Jquery autosuggest script by George Andriyanov.
In caller page do this:
<style>
.as_block{} // results
.highlight{} // a highlited result
</style>
<div id="as_result" style="position:absolute;left:0px;top:0px">This is the result container</div>
<script language="javascript">
as_class = ".class"; //class for text fields where autosuggest works
as_table = "table"; //source for results (Aktar CMS only)
as_server = "url"; //server-side handler with no args
</script>
<script language="javascript" src="/path/to/ajaxsearch.js"></script>
*/

$.ajaxSetup({
cache: true
})


$(as_class).keyup(function(e){
	as_caller = $(this);
	as_data = "tab=" + as_table + "&fld=" + as_caller.attr("name") + "&q=" + as_caller.val()
	$.ajax( { 
		type: "GET",
		url: as_server,
		data: as_data, 
    		success: function(msg){
			var offset = as_caller.offset();
			$("#as_result").css("top", $(as_caller).height()+offset.top+"px").css("left", offset.left+"px");
			$("#as_result").html(msg).slideDown("fast");
			hovers(".ajaxresult", "highlight")
			$(".ajaxresult").click(function(){
				as_caller.val($(this).html());
				$("#as_result").slideUp("fast");
			})
		},
		error: function (XMLHttpRequest, textStatus, errorThrown) {
  			$("#as_result").html(as_data);
		}	
	});
})

function hovers(el, elClass){
$(el).hover(
  function () {
    $(this).addClass(elClass);
  },
  function () {
    $(this).removeClass(elClass);
  }
);
}
