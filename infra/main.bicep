targetScope = 'resourceGroup'

@description('Azure region where resources will be deployed')
param location string = 'germanywestcentral'

@description('Environment name')
param environment string = 'dev'

@description('Project name used for resource naming')
param projectName string = 'nodejsdemo'

@description('Unique suffix for globally unique resource names')
@minLength(5)
@maxLength(10)
param uniqueSuffix string

@description('Azure Container Registry name')
var acrName = '${projectName}acr${uniqueSuffix}'

@description('Azure Container Registry')
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('App Service Plan name')
var appServicePlanName = '${projectName}-plan-${environment}'

@description('App Service Plan')
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

@description('Web App name')
var webAppName = '${projectName}-app-${uniqueSuffix}'

@description('Azure Web App')
resource webApp 'Microsoft.Web/sites@2025-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/nodejs-azure-cicd-demo:1.0'
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '3000'
        }
      ]
    }
  }
}

@description('AcrPull role assignment for Web App managed identity')
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, webApp.id, 'AcrPull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    )
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
