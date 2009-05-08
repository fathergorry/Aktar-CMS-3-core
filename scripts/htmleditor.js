//inspired by PhpBB

if (typeof(textareaEdit) == 'undefined'){textareaEdit = 'message'};




var useragent = navigator.userAgent.toLowerCase(); 
var is_ie = (useragent.indexOf('msie') != -1 && useragent.indexOf('opera') == -1);
var is_win = (useragent.indexOf('win') != -1 || useragent.indexOf('16bit') != -1);

var selRange = false;
var baseHeight;


function surnd(starttag, endtag, offset){
	selRange = false;
	var textarea = document.getElementById(textareaEdit);
	textarea.focus();

	if ((parseInt(navigator.appVersion) >= 4) && is_ie && is_win){
		selRange = document.selection.createRange().text;
		if (selRange){
			document.selection.createRange().text = starttag + selRange + endtag;
			textarea.focus();
			selRange = '';
			return;
		}
	}
	else if (textarea.selectionEnd && (textarea.selectionEnd - textarea.selectionStart > 0)){
		mozWrap(textarea, starttag, endtag);
		textarea.focus();
		selRange = '';
		return;
	}
	

	var new_pos = getCaretPosition(textarea).start + starttag.length + parseInt(offset);		

	instxt(starttag + endtag);

	if (!isNaN(textarea.selectionStart)){
		textarea.selectionStart = new_pos;
		textarea.selectionEnd = new_pos;
	}	
	// IE
	else if (document.selection){
		var range = textarea.createTextRange(); 
		range.move("character", new_pos); 
		range.select();
		sc(textarea);
	}

	textarea.focus();
	return;
}


function instxt(text){
	var textarea = document.getElementById(textareaEdit);
	if (!isNaN(textarea.selectionStart)){
		var sel_start = textarea.selectionStart;
		var sel_end = textarea.selectionEnd;

		mozWrap(textarea, text, '')
		textarea.selectionStart = sel_start + text.length;
		textarea.selectionEnd = sel_end + text.length;
	}
	else if (textarea.createTextRange && textarea.caretPos){
		if (baseHeight != textarea.caretPos.boundingHeight){
			textarea.focus();
			sc(textarea);
		}

		var caret_pos = textarea.caretPos;
		caret_pos.text = caret_pos.text.charAt(caret_pos.text.length - 1) == ' ' ? caret_pos.text + text + ' ' : caret_pos.text + text;
	}
	else{
		textarea.value = textarea.value + text;
	}
	textarea.focus();
}

function mozWrap(txtarea, open, close){
	var selLength = txtarea.textLength;
	var selStart = txtarea.selectionStart;
	var selEnd = txtarea.selectionEnd;
	var scrollTop = txtarea.scrollTop;

	if (selEnd == 1 || selEnd == 2) 
	{
		selEnd = selLength;
	}

	var s1 = (txtarea.value).substring(0,selStart);
	var s2 = (txtarea.value).substring(selStart, selEnd)
	var s3 = (txtarea.value).substring(selEnd, selLength);

	txtarea.value = s1 + open + s2 + close + s3;
	txtarea.selectionStart = selEnd + open.length + close.length;
	txtarea.selectionEnd = txtarea.selectionStart;
	txtarea.focus();
	txtarea.scrollTop = scrollTop;

	return;
}


// http://www.faqts.com/knowledge_base/view.phtml/aid/1052/fid/130

function sc(textEl){
	if (textEl.createTextRange){
		textEl.caretPos = document.selection.createRange().duplicate();
	}
}


function getCaretPosition(inzone){

var caretPos = {"start": null, "end" : null}

	if(inzone.selectionStart || inzone.selectionStart == 0){
		caretPos.start = inzone.selectionStart;
		caretPos.end = inzone.selectionEnd;
	}
	else if(document.selection || is_ie){
		var range = document.selection.createRange();
		var range_all = document.body.createTextRange();
		range_all.moveToElementText(inzone);
		var sel_start;
		for (sel_start = 0; range_all.compareEndPoints('StartToStart', range) < 0; sel_start++){		
			range_all.moveStart('character', 1);
		}
		inzone.sel_start = sel_start;
		caretPos.start = inzone.sel_start;
		caretPos.end = inzone.sel_start;			
	}

	return caretPos;
}
