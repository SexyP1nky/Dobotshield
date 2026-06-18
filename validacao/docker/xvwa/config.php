<?php
$XVWA_WEBROOT = "";
$host = getenv("XVWA_DB_HOST") ?: "xvwa_db";
$dbname = getenv("XVWA_DB_NAME") ?: "xvwa";
$user = getenv("XVWA_DB_USER") ?: "root";
$pass = getenv("XVWA_DB_PASS") ?: "root";

$conn = new mysqli($host, $user, $pass, $dbname);
$conn1 = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
$conn1->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>
