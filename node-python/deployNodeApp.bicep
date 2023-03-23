@description('Keyvault name')
param kvName string 
@description('Location')
param location string
@description('Version')
param nodeAppVersion string
@description('the assigned identity')
param identity string

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
  scope: resourceGroup()
}


module nodeappModule1 'nodeapp-containerapp.bicep' =  {
  name: 'deployNodeAppv1'
  params: {
    location: location
    identity: {
      '${identity}' : {}
    }
    environment_name: keyvault.getSecret('kvEnvName')
    custom_message: 'Version:v${nodeAppVersion}'
    revVersion: 'v${nodeAppVersion}'
    registry_login_server: keyvault.getSecret('kvAcrloginServer')
    registry_password: keyvault.getSecret('kvAcrPassword')
    registry_username: keyvault.getSecret('kvAcrUserName')
  }
}
