$target=$args[0]
$delegate=$args[1]
Add-MailboxFolderPermission -Identity $target@sense.tech:\Calendar -User $delegate@sense.tech -AccessRights Editor