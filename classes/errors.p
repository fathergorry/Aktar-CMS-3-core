
@auto[]
$errors_executed(1)

@errorHandler[error]

$cache_time(0)
$document.1[1]

^switch[$error]{
^case[404]{
	^if(!def $ignore_404){
		$document.content[^lang[449] 
		^if(!^is_from_site[]){
		 	^lang[450]
		}{
			^lang[451]
		}
		<p>
		^lang[452] 
		^lang[453] <a href="http://$env:SERVER_NAME">^lang[454]</a>  
		] $document.title[^lang[455]] $document.status[404] $document.pagetitle[^lang[455]]
     	^if($uri eq "/robots.txt" && -f "/robots.txt"){
	 		^robots[]
		}{
			^if(!def $globals.ignore_404){
				^rec404[$uri] $response:status[404]
			} 
		}
		}
	}
^case[403]{
	 $document.status[403]  $response:status[403] $response:body[Access denied]
	}
}


@noDB[path]
^if($caller.exception.type eq "sql.execute" && ^caller.exception.comment.pos[doesn't exist] > 0){
	$caller.exception.handled(1)$caller.minutes(0)
^process{@unhandled_exception[a^;b^;c^;d]
###
# ^^redirect[$path]
No tables in DB. Do <a href="/login/install">install</a>.
}
}
@rec404[link][rec]
^connect[$scs]{
  $rec[^table::sql{SELECT * FROM ^dtp[pages404] WHERE link = '$link'}]
  ^if(def $rec){
     ^if(def $rec.redirect){^redirect[$rec.redirect]}
     ^if($rec.pohui eq yes || def $rec.redirect){}{
      ^void:sql{UPDATE ^dtp[pages404] SET hits = hits + 1, useragent = '$env:HTTP_USER_AGENT' ^if(def $env:HTTP_REFERER){, referer = '$env:HTTP_REFERER'} WHERE link = '$link'}
     }
  }{
  ^void:sql{INSERT IGNORE INTO ^dtp[pages404] (link, hits, useragent, referer) VALUES ('$link', '1', '$env:HTTP_USER_AGENT', '$env:HTTP_REFERER')}
  }
}

@robots[][h]
$h[^file::load[text;/robots.txt]]
$response:content-type[text/plain]
$response:body[$h.text]
