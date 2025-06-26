@description('Name of the AVD host pool')
param hostPoolName string

@description('Location of the host pool')
param location string = resourceGroup().location

@description('Host pool type')
param hostPoolType string = 'Pooled'

@description('Preferred application group type')
param preferredAppGroupType string = 'Desktop'

@description('Registration token expiration time in ISO 8601 format (e.g. 2025-07-20T10:00:00Z)')
param expirationTime string

// Host Pool Resource
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-02-10-preview' = {
  name: hostPoolName
  location: location
  properties: {
    friendlyName: hostPoolName
    hostPoolType: hostPoolType
    preferredAppGroupType: preferredAppGroupType
    loadBalancerType: 'DepthFirst'
    validationEnvironment: false
  }
  tags: {
    environment: 'Production'
    project: 'AVD'
  }
}

// Registration Info (token) Resource — must be a child of hostPool
resource registrationInfo 'Microsoft.DesktopVirtualization/hostPools/registrationInfo@2022-02-10-preview' = {
  name: 'registrationInfo'
  parent: hostPool
  properties: {
    expirationTime: expirationTime
  }
}

// Output registration token value to use for session host registration
output registrationToken string = registrationInfo.properties.token

// Output full host pool resource ID (useful for passing as param to session hosts)
output hostPoolId string = hostPool.id
