@CLASS
file_object

@create[filename;directory]
$file[$filename]
^if(def $directory){$fpath[$directory/$file]}

@show[]
$f[^file:find[^if(def $directory)]]