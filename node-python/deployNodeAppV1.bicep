@description('Keyvault name')
param kvName string 

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
  scope: resourceGroup()
}

module nodeappModule 'nodeapp-containerappv1.bicep' = {
  name: 'deployNodeApp'
  params: {
    location: resourceGroup().location
    environment_name: keyvault.getSecret('kvEnvName')
    custom_message: 'v1'
    registry_login_server: keyvault.getSecret('kvAcrloginServer')
    registry_password: keyvault.getSecret('kvAcrPassword')
    registry_username: keyvault.getSecret('kvAcrUserName')
  }
}
