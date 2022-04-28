$domain=$args[0]
$user=$args[1]
Get-Mailbox $user@human-id.com -EmailAddresses @{Add="$user@$domain"}