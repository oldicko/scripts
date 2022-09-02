$domain=$args[0]
$user=$args[1]
Set-Mailbox $user@sense.tech -EmailAddresses @{Add="$user@$domain"}