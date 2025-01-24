@description('The tags to associate with the resource')
param tags object

param applicationInsightsConnectionString string

param keyVaultUri string

param databaseNames string[]

var uniqueName = uniqueString(resourceGroup().id, subscription().id)

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'sitePlan-${uniqueName}'
  tags: tags
  location: resourceGroup().location
  sku: {
    name: 'P0V3'
  }
  properties:{
    reserved: false
  }
  kind: 'app'
}

// Define the for loop result as a separate variable
var databaseAppSettings = [
  for dbName in databaseNames: {
    name: 'AZURE_SQL_${toUpper(dbName)}_CONNECTION_STRING_KEY'
    value: 'AZURE-SQL-${toUpper(dbName)}-CONNECTION-STRING'
  }
]

// Define the additional app settings
var additionalAppSettings = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsightsConnectionString
  }
  {
    name: 'AZURE_KEY_VAULT_ENDPOINT'
    value: keyVaultUri
  }
]

resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = {
  name: 'site-${uniqueName}'
  tags: union(tags, { 'azd-service-name': 'website' })
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
     acrUseManagedIdentityCreds: false
     netFrameworkVersion:'v8.0'
     appSettings: union(
      databaseAppSettings,
      additionalAppSettings
    )
    }
  }  
  identity: {
    type: 'SystemAssigned'
 }
}

output principalId string = appServiceApp.identity.principalId
output webAppName string = appServiceApp.name
output webAppUrl string = 'https://${appServiceApp.properties.defaultHostName}'
