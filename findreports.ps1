param(
    [Parameter(Mandatory=$true)]
    [string]$AccessToken,

    [Parameter(Mandatory=$true)]
    [string]$JobTitle,

    [Parameter(Mandatory=$true)]
    [string]$EmailAddress,

    [Parameter(Mandatory=$false)]
    [string]$CsvPath = ".\MatchingReports.csv"
)

# Define authorization headers
$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

# Use a generic list for better performance during recursion
$matchedUsers = New-Object System.Collections.Generic.List[PSCustomObject]

function Get-DirectReportsRecursive {
    param (
        [string]$UserPrincipalName,
        [string]$ManagerName
    )

    # Graph API endpoint for direct reports. Explicitly selecting properties speeds up the query.
    $uri = "https://graph.microsoft.com/v1.0/users/$UserPrincipalName/directReports?`$select=id,displayName,mail,jobTitle"

    while ($uri) {
        try {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        } catch {
            Write-Error "Failed to query direct reports for $UserPrincipalName. Ensure the token has User.Read.All permissions."
            break
        }

        foreach ($user in $response.value) {
            # Check if the job title matches (PowerShell -eq is case-insensitive by default)
            if ($user.jobTitle -eq $JobTitle) {
                $matchedUsers.Add([PSCustomObject]@{
                    Name        = $user.displayName
                    Email       = $user.mail
                    ManagerName = $ManagerName
                })
            }

            # Recursive call: pass the current user's ID and Name to check their direct reports
            Get-DirectReportsRecursive -UserPrincipalName $user.id -ManagerName $user.displayName
        }

        # Handle pagination if the user has more direct reports than the default Graph API return limit
        $uri = $response.'@odata.nextLink'
    }
}

# 1. Retrieve the starting user's display name to assign as the first manager
try {
    $startUserUri = "https://graph.microsoft.com/v1.0/users/$EmailAddress?`$select=displayName"
    $startUser = Invoke-RestMethod -Uri $startUserUri -Headers $headers -Method Get
    $startManagerName = $startUser.displayName
} catch {
    Write-Error "Failed to retrieve the starting user '$EmailAddress'. Script terminating."
    exit
}

# 2. Initiate the recursive search
Write-Host "Querying organizational structure below $startManagerName..."
Get-DirectReportsRecursive -UserPrincipalName $EmailAddress -ManagerName $startManagerName

# 3. Export results to CSV
if ($matchedUsers.Count -gt 0) {
    $matchedUsers | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-Host "Execution complete, Sir. Found $($matchedUsers.Count) matching individuals. Results exported to $CsvPath."
} else {
    Write-Host "Execution complete, Sir. Zero individuals found with the job title '$JobTitle' under $startManagerName."
}