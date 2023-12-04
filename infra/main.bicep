param username string
@sys.description('The username to use for the deployment')

param containerRegistryName string
@sys.description('The name of the container registry')

// param containerRegistryImageName string
// @sys.description('The name of the container image')

// param containerRegistryImageVersion string
// @sys.description('The version of the container image')

param appServicePlanName string
@sys.description('The name of the app service plan')

param appName string
@sys.description('The name of the app')

param location string = resourceGroup().location
@sys.description('The location of the resources')

module registry 'modules/container-registry/registry/main.bicep' = {
  name: '${uniqueString(deployment().name)}-acr'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
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
    registry
    serverfarm
  ]
  name: 'exercise3-${username}-app'
  params: {
    name: appName
    location: location
    kind: 'app'
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      // linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://${containerRegistryName}.azurecr.io'
    }
  }
}
