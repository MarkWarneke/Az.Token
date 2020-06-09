function Get-AppSettings {
    <#
    .SYNOPSIS
    Creates AppSettings based on template

    .DESCRIPTION
    Creates AppSettings based on template, replaces %TOKEN% in appsettings.template.*.json with actual values from Azure KeyVault

    .PARAMETER subscriptionId
    Subscription id of the key vault (needs to be logged in `Connect-AzAccount` )

    .PARAMETER VaultName
    Azure KeyVault that stores the actual secrets

    .EXAMPLE
    Get-AppSettings -VaultName MyKeyVault
    #>

    [CmdletBinding()]
    param (
        $subscriptionId,
        $VaultName,
        $Path,
        $delimiter = "%",
        $Filter = 'appsettings.json',
        $OutFileName = 'appsettings.json'
    )

    begin {
        $context = Set-AzContext $subscriptionId
        Write-Verbose "Conntected to $($context.Name) $subscriptionId"

        $null = Get-AzKeyVault -VaultName $VaultName -ErrorAction Stop
        Write-Verbose "Querying KeyVault $VaultName"

        $secrets = Get-AzKeyVaultSecret -VaultName $VaultName -ErrorAction Stop
        Write-Verbose "Secrets found $($secrets.Count) in $VaultName"
    }

    process {
        Write-Verbose "Searching for $Filter in $Path"
        $appsettingsFiles = Get-ChildItem -Recurse $Path -Filter $Filter

        foreach ($file in $appsettingsFiles) {
            Write-Verbose "Found Appsettings $file"

            $parentPath = split-path $file -Parent
            Write-Verbose "Settings located in $parentPath"

            $json = Get-Content $file -Raw

            foreach ($secretToken in $secrets) {
                $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $secretToken.Name
                Write-Verbose "Replacing $($secret.Name) in $file"

                $token = "{0}{1}{0}" -f $delimiter, $secret.Name
                $json = $json.Replace($token , $secret.SecretValueText)
            }

            $return = [PSCustomObject]@{
                AppsettingsFile = $file.Name
                OutFileName     = $OutFileName
                Content         = $json
                Path            = $parentPath
            }

            $return
        }

    }

    end {
    }
}
