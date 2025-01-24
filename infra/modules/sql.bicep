param sqlAdministratorLoginUser string

@secure ()
param sqlAdministratorLoginPassword string

@description('The tags to associate with the resource')
param tags object

param databaseNames string[]

var uniqueName = uniqueString(resourceGroup().id, subscription().id)

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
   name: 'sqlserver-${uniqueName}'
   tags: tags
   location: resourceGroup().location
  properties: {
    administratorLogin: sqlAdministratorLoginUser
    administratorLoginPassword: sqlAdministratorLoginPassword
  }
}

resource databases 'Microsoft.Sql/servers/databases@2021-11-01' = [for dbName in databaseNames: {
  name: dbName
  parent: sqlServer
  tags: tags
  location: resourceGroup().location
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824 //1GB
    autoPauseDelay: 60
    zoneRedundant: false
    requestedBackupStorageRedundancy: 'Local'
    isLedgerOn: false
  }
}]

resource sqlserverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  name: 'AllowAllIPs'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

output sqlServerFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
