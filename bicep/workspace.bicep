@description('Workspace name')
param workspaceName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('App Group resource ID')
param appGroupResourceId string

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2022-02-10-preview' = {
  name: workspaceName
  location: location
  properties: {
    description: workspaceName
    friendlyName: workspaceName
    applicationGroupReferences: [
      appGroupResourceId
    ]
  }
  // dependsOn: [ appGroupResource ] // uncomment if appGroupResource is declared in same file
  tags: {
    environment: 'Production'
    project: 'AVD'
  }
}
