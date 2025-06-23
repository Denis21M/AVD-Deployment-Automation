@description('Name of the Application Group')
param appGroupName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Host Pool Resource ID')
param hostPoolResourceId string

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-02-10-preview' = {
  name: appGroupName
  location: location
  properties: {
    friendlyName: appGroupName
    hostPoolArmPath: hostPoolResourceId
    applicationGroupType: 'Desktop'
  }
  tags: {
    environment: 'Production'
    project: 'AVD'
  }
}
