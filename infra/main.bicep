targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

var tags = {
  'azd-env-name': environmentName
  SecurityControl: 'Ignore'
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

var uniqueName = uniqueString(rg.id, subscription().id)
var sqlAdministratorUser = 'eshopOnWebAdmin'
var sqlAdministratorLoginPassword = '${uniqueName}${uniqueName}!'
var keyVaultName = 'vault-${uniqueName}'
var databaseNames = [
  'Catalog'
  'Identity'
]

module sql 'modules/sql.bicep' = {
  name: 'sql'
  scope: rg
  params: {
    sqlAdministratorLoginUser: sqlAdministratorUser
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    tags: tags
    databaseNames: databaseNames
  }
}

module appInsights 'modules/applicationInsights.bicep' ={
  name: 'appInsights'
  scope: rg
  params: {
    tags: tags
  }  
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault'
  scope: rg
  params: {
    keyVaultName: keyVaultName
    sqlAdministratorLoginUser: sqlAdministratorUser
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    databaseNames: databaseNames
    sqlServerFullyQualifiedDomainName: sql.outputs.sqlServerFullyQualifiedDomainName
    tags: tags
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  scope: rg
  params: {
    tags: tags
    databaseNames: databaseNames
    keyVaultUri: keyVault.outputs.endpoint
    applicationInsightsConnectionString: appInsights.outputs.connectionString
  }
}

module keyVaultAssignment 'modules/keyVaultAssignment.bicep' = {
  name: 'keyVaultAssignment'
  scope: rg
  params: {
    keyVaultName: keyVaultName
    appServicePrincipalId: appService.outputs.principalId
  }
}


output AZURE_APP_URL string = appService.outputs.webAppUrl
output AZURE_SQL_FQDN string = sql.outputs.sqlServerFullyQualifiedDomainName
output SQL_ADMIN_LOGIN string = sqlAdministratorUser
#disable-next-line outputs-should-not-contain-secrets
output SQL_ADMIN_PASSWORD string = sqlAdministratorLoginPassword
