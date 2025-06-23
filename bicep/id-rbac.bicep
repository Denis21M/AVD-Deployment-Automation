param location string = resourceGroup().location
param imageName string
param subnetId string
param galleryId string

var vnetId = substring(subnetId, 0, lastIndexOf(subnetId, '/subnets/'))

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'avdImageBuilderIdentity'
  location: location
}

resource contributorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uami.id, 'contributor-role')
  scope: resourceGroup()
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor
    principalType: 'ServicePrincipal'
  }
}

resource networkContributorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uami.id, 'network-contributor-role')
  scope: vnetId
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor
    principalType: 'ServicePrincipal'
  }
}

module imageTemplate 'image-temp.bicep' = {
  name: 'imageTemplateModule'
  params: {
    location: location
    imageName: imageName
    subnetId: subnetId
    identityId: uami.id
  }
}
