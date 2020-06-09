[CmdletBinding()]
param (
    $subscriptionId,
    $VaultName,
    $Path = "Test",
    $Delimiter = "%"
)

# Source the script
. "./New-AppSettings.ps1"

# Exceute the script to create appsettings.json
Get-AppSettings -SubscriptionId $SubscriptionId -VaultName $VaultName -Path $Path -Delimiter $Delimiter | 
    ForEach-Object { 
        Out-File -InputObject $_.Content -FilePath (Join-Path $_.Path $_.OutFileName) -Confirm
    }
