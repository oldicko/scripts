$email=$args[0]
$username=$args[1]
$newEmail="$username@human-id.com"
$userObject=(Get-User -Identity $email).ExternalDirectoryObjectId
Set-AzureADUser -objectid $userObject -UserType "Member"
Set-MsolUserLicense -UserPrincipalName $email -AddLicenses stealthdev:O365_BUSINESS_ESSENTIALS
Set-MsolUserPrincipalName -UserPrincipalName $email -NewUserPrincipalName $newEmail
Set-MsolUser -UserPrincipalName $newEmail -UsageLocation "CA"
Set-MsolUserPassword -UserPrincipalName $newEmail -ForceChangePassword $true