<?php

// - Edit Variables -
$auth_token = '';
$sub_domain = '';

// - Don't Edit Below -
$base_url = "https://$sub_domain.instructure.com/api/v1/accounts/self/users";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $base_url);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, array( 'Authorization: Bearer ' .$auth_token));
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST'); 
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_POSTFIELDS, array(
    // - Edit Params -
    'user[name]' => 'Test User',
    'user[short_name]' => 'test_user',
    'pseudonym[unique_id]' => '1122',
));
curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
curl_setopt($ch);
$curlData = curl_exec($ch);
curl_close($ch);

?>