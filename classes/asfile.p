

@asfile[][]
$sef.asfile[$form:asfile]

$rfile[^file::load[text;/my/file_content$sef.asfile]]
^if(^rfile.text.pos[@main[]] >=0 && ^rfile.text.pos[@content[]] >= 0){^store_file[]}{^prepare_file[]}
$result[]
@store_file[][f2;f3]
$f2[@main[]
^^makepage[$uri]]
$f3[@content[]]
$rfiledata[$f2
$f3
^taint[as-is][^if(def $sef.content){$sef.content}{ }]]
^if(^sef.content.length[] >= 2){^rfiledata.save[/my/file_content$sef.asfile] $sef.content[]}
@prepare_file[][tmp]
$rtitle[-]$rkeywords[-]$rdescription[-]$rcontent[-]$rh1[-]

$tmp[$rfile.text]
$tmp[^tmp.match[<title>(.+)</title>][ig]{$rtitle[$match.1]}]
$rtitle[^rtitle.match[‡][ig]{*}]
$tmp[^tmp.match[(<meta[^^>]*)content="([^^"]+)"([^^>]*>)][ig]{^rads[${match.1}src="$inui[$match.2]$match.2"${match.3}]}]
$tmp[^tmp.match[(<h1[^^>]*)>(.+?)(</h1>)][i]{$rh1[$match.2]}]
$tmp[^tmp.match[\^^macro\[top^;0^;0^;0\](.+)\^^macro\[btm^;0^;0^;0\]][ig]{$rcontent[$match.1]}]
$rh1[^rh1.match[<(.+?)>][ig]{}]
$rcontent[^rcontent.match[</noindex>|<o:p>|</o:p>|(<span[^^>]*)>|</span>][ig]{}]
$rcontent[^rcontent.match[<p[^^>]*][ig]{<p}]
$sef.content[$rcontent]
$sef.description[$rdescription]
$sef.keywords[$rkeywords]
$sef.title[$rtitle]
$sef.pagetitle[$rh1]
^store_file[]
@rads[str]
$str[^str.lower[]]
^if(^str.pos[description] >= 0){$rdescription[$inui]}
^if(^str.pos[keywords] >= 0){$rkeywords[$inui]}
