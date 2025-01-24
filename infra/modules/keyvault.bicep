@description('The tags to associate with the resource')
param tags object

param keyVaultName string

param sqlServerFullyQualifiedDomainName string
param databaseNames string[]

param sqlAdministratorLoginUser string

@secure ()
param sqlAdministratorLoginPassword string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  tags: tags
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [for dbName in databaseNames: {
  name: 'AZURE-SQL-${toUpper(dbName)}-CONNECTION-STRING'
  tags: tags
  parent: keyVault
  properties: {
    value: 'Data Source=tcp:${sqlServerFullyQualifiedDomainName},1433;Initial Catalog=${dbName};Persist Security Info=False;User Id=${sqlAdministratorLoginUser};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;'
  }
}]

output endpoint string = keyVault.properties.vaultUri
