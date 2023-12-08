param username string
@sys.description('The username to use for the deployment')

param containerRegistryName string
@sys.description('The name of the container registry')

param containerRegistryImageName string
@sys.description('The name of the container image')

param containerRegistryImageVersion string
@sys.description('The version of the container image')

param appServicePlanName string
@sys.description('The name of the app service plan')

param appName string
@sys.description('The name of the app')

param location string = resourceGroup().location
@sys.description('The location of the resources')

param keyVaultName string
@sys.description('The name of the key vault')

param keyVaultSecretNameACRUsername string = 'acr-username'
@sys.description('The name of the key vault secret for the ACR username')

param keyVaultSecretNameACRPassword1 string = 'acr-password1'
@sys.description('The name of the key vault secret for the first ACR password')

param keyVaultSecretNameACRPassword2 string = 'acr-password2'
@sys.description('The name of the key vault secret for the second ACR password')

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}
module registry 'modules/container-registry/registry/main.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: '${uniqueString(deployment().name)}-acr'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
    adminCredentialsKeyVaultSecretUserName: keyVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: keyVaultSecretNameACRPassword1
    adminCredentialsKeyVaultSecretUserPassword2: keyVaultSecretNameACRPassword2
  }
}

module serverfarm 'modules/web/serverfarm/main.bicep' = {
  name: '${uniqueString(deployment().name)}-asp'
  params: {
    name: appServicePlanName
    location: location
    sku: {  
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

module website 'modules/web/site/main.bicep' = {
  dependsOn: [
    serverfarm
  ]
  name: 'exercise3-${username}-app'
  params: {
    name: appName
    location: location
    kind: 'app'
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DUMMY: registry.outputs.name
    }
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUsername: keyVault.getSecret(keyVaultSecretNameACRUsername)
    dockerRegistryServerPassword: keyVault.getSecret(keyVaultSecretNameACRPassword1)
  }
}
