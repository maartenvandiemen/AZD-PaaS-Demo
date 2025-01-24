#!/usr/bin/env pwsh

# Navigate to the src/Web directory
Set-Location -Path "src/Web"

# Restore .NET tools
dotnet tool restore

dotnet ef migrations script --output catalog.sql --idempotent --context catalogcontext
dotnet ef migrations script --output identity.sql --idempotent --context appidentitydbcontext

Install-Module -Name SqlServer -AllowClobber -Force


try {
    Invoke-Sqlcmd -ServerInstance "${env:AZURE_SQL_FQDN}" -Database "Catalog" -Username "${env:SQL_ADMIN_LOGIN}" -Password "${env:SQL_ADMIN_PASSWORD}" -InputFile "catalog.sql"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to execute catalog.sql"
    }

    Invoke-Sqlcmd -ServerInstance "${env:AZURE_SQL_FQDN}" -Database "Identity" -Username "${env:SQL_ADMIN_LOGIN}" -Password "${env:SQL_ADMIN_PASSWORD}" -InputFile "identity.sql"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to execute identity.sql"
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

Write-Output "Succesfully deployed databases"

Remove-Item -Path catalog.sql -ErrorAction SilentlyContinue
Remove-Item -Path identity.sql -ErrorAction SilentlyContinue

# Navigate back to the original directory
Set-Location -Path $PSScriptRoot