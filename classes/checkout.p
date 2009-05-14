@CLASS
checkout
#Проверка совместимости с уже загруженным кодом
#Поместите вызов ^checkout:file перед вызовом ваших модулей.
@file[path]
<p>
<b>Результаты проверки $path на совместимость с Aktar CMS.</b><br>
^if(-f "$path"){
$code[^file::load[text;$path]]
^checkfile[$code.text]
}{Ура, этот файл не существует!}
<p>

@checkfile[txt]
$ops[^table::create{op}]
$vars[^hash::create[]]
$vartxt[^txt.split[@CLASS;lh]]
$vartxt[$vartxt.0]

$babyfrog[@]
$optxt[^txt.replace[^table::create{f	t
${babyfrog}CLASS	
${babyfrog}USE	
${babyfrog}BASE	}]]

$a[
^optxt.match[(\n@)(.+?)(\^[)][ig]{^ops.append{$match.2}}
#какой-то пиздец ^vartxt.match[(\^$^{|\^$|\^^)(.+?)(^[\^]\' &/\^}\^)\^;\^{\^[\^(\.\:^])][ig]{$vars.[$match.2](1)}
^vartxt.match[(\^$^{|\^$)(.+?)(^[\^{\^[\^(\.\:^])][ig]{$vars.[$match.2](1)}

]

$ops[^ops.select($MAIN:[$ops.op] is junction && $ops.op ne main && $ops.op ne auto)]
^ops.sort{$ops.op}
^if(def $ops){ $checkfail(1)
Эти операторы уже определены в классе MAIN:<br>
^ops.menu{$ops.op<br>}
}

$vars[^table::create{var
^vars.foreach[k;v]{$k}[
]}]
$vars[^vars.select(def $MAIN:[$vars.var])]
^vars.sort{$vars.var}
^if(def $vars){$checkfail(1)<p>Эти переменные уже присутствуют в классе MAIN:<br>}
^vars.menu{$vars.var<br>}
^if(!$checkfail){Вроде, всё в порядке...}
