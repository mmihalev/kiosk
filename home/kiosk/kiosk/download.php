<?php

$allowed_ips = array('212.50.20.44', '78.83.221.216', '10.0.2.15', '10.4.4.58');

if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $ip = $_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
} else {
    $ip = $_SERVER['REMOTE_ADDR'];
}

if(!in_array($ip, $allowed_ips))
{
    die("Access denied");
}

if( isset($_REQUEST["file"]) && isset($_REQUEST["transfer"]) && trim($_REQUEST["file"]) !== "" && trim($_REQUEST["transfer"]) !== "" )
{
    $file = trim($_REQUEST["file"]);
    $transfer = (int) trim($_REQUEST["transfer"]);

    exec("/home/kiosk/download.sh $file $transfer > /dev/null &");
    exit("ok");
}else{
    die("Wrong params");
}
?>