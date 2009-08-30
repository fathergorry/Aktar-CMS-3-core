<?php

$a = chmod("../../../cgi-bin/parser3", 0755);
$b = chmod("../../../cgi-bin/nconvert", 0755);
if($a)
$color = "green";
else
$color = "red";
print "<div align=center style=\"border:3px solid $color;padding:28px;margin:28px\"><big><b>";
if ($a)
print "Parser chmod OK, <a href=/login/install/>proceed</a> or redirecting in 10 secs... <meta http-equiv=\"refresh\" content=\"10;url=/login/install/\">";
else {
print "Unable to activate Parser in cgi-bin/parser3. File must be named parser3 (no extension!) and compiled under this operating system (see info below).";
};

print "</div></big></b>";
phpinfo();

?>
