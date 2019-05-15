<?php
// Set error reporting.
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Get script path.
$path=__FILE__;
// If is a link then get path from it.
if (is_link($path))
    $path = readlink($path);
// Get working directory from the script path.
$dir=dirname($path);

// Command to initialize/update status HTML-file.
$cmd="$dir/../make_html_status.sh";
// Path for status HTML-file.
$html_path="$dir/status.html";

// Run command.
system($cmd, $res);
// No permission to run the command.
if($res === 126)
    die("No permission to run command `$cmd`!");
// Command failed.
elseif($res !== 0)
    die("Command `$cmd` failed with a code `$res`");
// HTML-file exists and is readable.
elseif(is_readable($html_path))
    readfile($html_path);
// No HTML-file or it is not readable.
else
    die("No file `$html_path` or no permission to read it!");