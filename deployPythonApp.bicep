@description('Keyvault name')
param kvName string 
@description('Location')
param location string


resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
  scope: resourceGroup()
}

module nodeappModule1 'pythonapp-containerapp.bicep'=  {
  name: 'deployPythonAppv1'
  params: {
    location: location
    environment_name: keyvault.getSecret('kvEnvName')
    registry_login_server: keyvault.getSecret('kvAcrloginServer')
    registry_password: keyvault.getSecret('kvAcrPassword')
    registry_username: keyvault.getSecret('kvAcrUserName')
  }
}
