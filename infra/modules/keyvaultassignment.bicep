param keyVaultName string
param appServicePrincipalId string

resource createdkeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: createdkeyVault
  name: guid(keyVaultName, resourceGroup().id, appServicePrincipalId, 'Key Vault Secrets User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: appServicePrincipalId
  }
}
