$username=$args[0]
$oldEmail="$username@human-id.com"
$newEmail="$username@sense.tech"
Set-MsolUserPrincipalName -UserPrincipalName $oldEmail -NewUserPrincipalName $newEmail