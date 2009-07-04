
@pizdec[]
^recover_obligate_files[]


@recover_fac_files[dir][all]
$all[^file:list[$dir]]
^all.menu{
	^if(-d "$dir/$all.name"){
	^recover_fac_files[$dir/$all.name]}{
		^recover_files[^dir.mid(15;99)/$all.name]
	}
}

@recover_obligate_files[]
^recover_fac_files[/login/recover]
^recover_files[
files/.htaccess
img/.htaccess
dbs/structure.txt
dbs/sections.txt
dbs/news.txt
dbs/pages404.txt
dbs/forum.txt
dbs/ans.txt
dbs/rating.txt
dbs/usergroups.txt
.htaccess
;obligate]

@recover_files[files;obligate][locals]
$files[^table::create{file
^untaint{$files}}]
^files.menu{
	^if(-f "/login/recover/$files.file" && (!-f "/my/$files.file" || def $obligate)){
		^file:copy[/login/recover/$files.file;/my/$files.file]
	}
}

@conf_init[]
$hStruc[^hash::create[]]
#list of site-related tables in DB
^connect[$scs]{
	$t[^table::sql{SHOW TABLES}]
	$tc[^t.columns[]]
	$dtp0[^dtp[]]
	$dtp0[^dtp0.length[]]
	$t[^t.select(^t.[$tc.column].pos[^dtp[]] == 0)]
	^t.menu{$hStruc.[^t.[$tc.column].mid($dtp0;255)](1)}
}
#list of structure tables
	$dbs[^file:list[/my/dbs;\.txt^$]]
	^dbs.menu{$hStruc.[^file:justname[$dbs.name]](1)}
	$predef[^file:list[/login/recover/dbs]]
	^predef.menu{$hStruc.[^file:justname[$predef.name]](1)}
	$tabak[^file:list[/my/tabak;\.txt^$]]
	^tabak.menu{$hStruc.[^file:justname[$tabak.name]](1)}

$tStruc[^table::create{name
^hStruc.foreach[k;v]{$k}[
]}]
^tStruc.sort{$tStruc.name}

@finish_install[]
$htaccess[<Files ~ ".">
Order allow,deny
Deny from all
</Files>]
^htaccess.save[/login/install/.htaccess]
/login/install/.htaccess created to prevent access to install files. <a href="/login">Log in</a>

@dbob[ts;act][tdb]
^use[dbobj.p]
$tdb[^dbobj::create[$ts]]
^tdb.CreateDBImage[^if($act eq install){unsafe}]
^die[Table ^dtp[]$ts ^if($act eq install){reinstalled;updated}.]

@resetts[ts]
^file:copy[/login/recover/dbs/${ts}.txt;/my/dbs/${ts}.txt]
^try{^file:copy[/login/recover/tabak/${ts}.tabak;/my/tabak/${ts}.tabak]}{^blad[]}
^die[Old '${ts}' is ready for restore.]

@install_language[]
^il2[/login/config/_language.txt]
^if(-f "/my/config/_language.txt"){^il2[/my/config/_language.txt]}
@il2[path]
$tlang[^table::load[$path]]
$columns[^tlang.columns[]]
$columns[^columns.select($columns.column ne "id" && $columns.column ne "exist")]
^columns.menu{
	$hflang[^hashfile::open[/my/deriv/$columns.column]]
	^tlang.menu{$hflang.[$tlang.id][$tlang.[$columns.column]]}
	^hflang.release[]
}
Created languages: ^columns.menu{$columns.column}[, ].<br>
1st record is
<b>$hflang.1</b>
