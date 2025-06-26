@description('Name of the AVD host pool')
param hostPoolName string

@description('Location of the host pool')
param location string = resourceGroup().location

@description('Host pool type')
param hostPoolType string = 'Pooled'

@description('Preferred application group type')
param preferredAppGroupType string = 'Desktop'

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

// Output full host pool resource ID (useful for passing as param to session hosts)
output hostPoolId string = hostPool.id
