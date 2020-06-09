# Az.Token � 👩‍💻👨‍💻

Creates `AppSettings.json` based on a tokenized template. Replaces `%TOKEN%` in `appsettings.json` with actual values from Azure KeyVault secrets that match `TOKEN` to create  `appsettings.dev.json`. ☁️

Will search recursively given `-Path` for files that match `-Filter`, by default it searches for `appsettings.json` files. The script queries all secrets inside a given Azure KeyVault by `-VaultName`. Replaces the found tokens matching `-delimiter` (e.g. `"%MYSQL_CONNECTION_STRING%"`) with the value from the Azure KeyVault secret with name `MYSQL_CONNECTION_STRING`.

## Example

Turns given template `appsettings.json`

```json
# appsettings.json
{
    "Logging": {
     ...
    },
    "AllowedHosts": "*",
    "ConnectionString" : "%MYSQL_CONNECTION_STRING%"
}
```

Using the method `Get-AppSettings`, queries the given Azure KeyVault for the secret with name `MYSQL_CONNECTION_STRING` and replaces the token with its actual secret value.

```powershell
# Login to Azure Account
Connect-AzAccount

# Create appsettings.json based 
Get-AppSettings -VaultName MyKeyVault -subscriptionId XXXXX | Out-File "appsettings.dev.json"
```

Createa a file `appsettings.dev.json` containing the secret values from the Azure KeyVault.

```json
# appsettings.dev.json
{
    "Logging": {
     ...
    },
    "AllowedHosts": "*",
    "ConnectionString" : "Server=myServerAddress;Database=myDataBase;Uid=myUsername;Pwd=myPassword;"
}
```

## Usage ⚠️

Create a `.gitignore` entry for `*\**\appsettings.*.json` and create an `appsettings.json` template using delimitered token that match the Azure KeyVault secret name. Run `Get-AppSettings` to create actual appsettings files that can be consumed in the code. Make sure to **NOT** check-in the new appsettings files, as credentials could be leaked.

