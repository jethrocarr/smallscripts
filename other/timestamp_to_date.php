#!/usr/bin/php
<?php

$timestamp = $argv[1];

if (!$timestamp)
{
	die("Please supply the timestamp as a command-line option.\n");
}



print date("Y-m-d H:i:s", $timestamp) ."\n";



?>
